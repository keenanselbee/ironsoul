#include "pch.h"

#include "dynamic_book.h"

#include "config.h"
#include "identity.h"
#include "journal_book.h"
#include "pathutil.h"

#include <algorithm>
#include <cctype>
#include <cstdint>
#include <cstring>
#include <exception>
#include <sstream>
#include <vector>

namespace fs = std::filesystem;

namespace IronSoul::DynamicBook
{
namespace
{
	constexpr std::string_view kMarkerPrefix = "[IronSoulDynamicBook:";
	constexpr std::string_view kResolvedMarkerPrefix = "[IronSoulDynamicBookResolved:";
	constexpr std::string_view kEmptySentinel = "[Empty]";
	constexpr std::string_view kDisplayRoot = "Data/SKSE/plugins/ironsoul/";
	constexpr std::string_view kImagePrefix = "img://";
	constexpr std::string_view kTextureRoot = "Textures/";
	constexpr std::string_view kRefreshPath = "_root.IronSoulSetDynamicBookText";
	constexpr std::string_view kSetBookTextMethod = "SetBookText";
	constexpr std::string_view kOghmaBookId = "ironsoul-oghma-infinium";
	constexpr std::size_t kMaxImages = 32;

	using FxDelegateInvoke_t = void (*)(RE::GFxMovieView*, const char*, RE::FxResponseArgsBase&);
	using ProcessMessage_t = RE::UI_MESSAGE_RESULTS (*)(RE::BookMenu*, RE::UIMessage&);

	struct ImageReference
	{
		std::string sourcePath;
		std::string url;
	};

	class DynamicBookSink : public RE::BSTEventSink<RE::MenuOpenCloseEvent>
	{
	public:
		RE::BSEventNotifyControl ProcessEvent(
			const RE::MenuOpenCloseEvent* a_event,
			RE::BSTEventSource<RE::MenuOpenCloseEvent>*) override;
	};

	DynamicBookSink g_sink;
	bool g_sinkRegistered = false;
	bool g_hooksRegistered = false;
	FxDelegateInvoke_t g_setBookTextInvoke = nullptr;
	ProcessMessage_t g_processMessage = nullptr;

	bool InfoLoggingEnabled()
	{
		return IronSoul::Config::ShouldEmitInfoLog();
	}

	std::string TrimCopy(std::string_view a_value)
	{
		const auto first = a_value.find_first_not_of(" \t\r\n");
		if (first == std::string_view::npos) {
			return {};
		}
		const auto last = a_value.find_last_not_of(" \t\r\n");
		return std::string(a_value.substr(first, last - first + 1));
	}

	bool IsValidBookId(std::string_view a_bookId)
	{
		if (a_bookId.empty()) {
			return false;
		}
		for (const char c : a_bookId) {
			if (!((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '_' || c == '-')) {
				return false;
			}
		}
		return true;
	}

	bool EqualsIgnoreCase(std::string_view a_lhs, std::string_view a_rhs)
	{
		if (a_lhs.size() != a_rhs.size()) {
			return false;
		}
		for (std::size_t i = 0; i < a_lhs.size(); ++i) {
			if (std::tolower(static_cast<unsigned char>(a_lhs[i])) != std::tolower(static_cast<unsigned char>(a_rhs[i]))) {
				return false;
			}
		}
		return true;
	}

	bool StartsWithIgnoreCase(std::string_view a_value, std::string_view a_prefix)
	{
		return a_value.size() >= a_prefix.size() && EqualsIgnoreCase(a_value.substr(0, a_prefix.size()), a_prefix);
	}

	bool EndsWithIgnoreCase(std::string_view a_value, std::string_view a_suffix)
	{
		return a_value.size() >= a_suffix.size() && EqualsIgnoreCase(a_value.substr(a_value.size() - a_suffix.size()), a_suffix);
	}

	std::size_t FindIgnoreCase(std::string_view a_text, std::string_view a_needle, std::size_t a_start = 0)
	{
		if (a_needle.empty() || a_start >= a_text.size()) {
			return std::string_view::npos;
		}
		for (std::size_t i = a_start; i + a_needle.size() <= a_text.size(); ++i) {
			if (EqualsIgnoreCase(a_text.substr(i, a_needle.size()), a_needle)) {
				return i;
			}
		}
		return std::string_view::npos;
	}

	void SkipWhitespace(std::string_view a_text, std::size_t& a_index)
	{
		while (a_index < a_text.size() && std::isspace(static_cast<unsigned char>(a_text[a_index]))) {
			++a_index;
		}
	}

	bool IsAttributeBoundary(std::string_view a_tag, std::size_t a_start, std::size_t a_end)
	{
		const auto isNameChar = [](char a_char) {
			return std::isalnum(static_cast<unsigned char>(a_char)) || a_char == '_' || a_char == '-';
		};
		return (a_start == 0 || !isNameChar(a_tag[a_start - 1])) &&
			(a_end >= a_tag.size() || !isNameChar(a_tag[a_end]));
	}

	std::optional<std::string_view> ExtractImageSource(std::string_view a_tag)
	{
		std::size_t searchStart = 0;
		while (true) {
			const std::size_t srcStart = FindIgnoreCase(a_tag, "src", searchStart);
			if (srcStart == std::string_view::npos) {
				return std::nullopt;
			}

			const std::size_t srcEnd = srcStart + 3;
			if (!IsAttributeBoundary(a_tag, srcStart, srcEnd)) {
				searchStart = srcEnd;
				continue;
			}

			std::size_t cursor = srcEnd;
			SkipWhitespace(a_tag, cursor);
			if (cursor >= a_tag.size() || a_tag[cursor] != '=') {
				searchStart = srcEnd;
				continue;
			}
			++cursor;
			SkipWhitespace(a_tag, cursor);
			if (cursor >= a_tag.size() || (a_tag[cursor] != '\'' && a_tag[cursor] != '\"')) {
				return std::nullopt;
			}

			const char quote = a_tag[cursor++];
			const std::size_t valueStart = cursor;
			const std::size_t valueEnd = a_tag.find(quote, valueStart);
			if (valueEnd == std::string_view::npos) {
				return std::nullopt;
			}
			return a_tag.substr(valueStart, valueEnd - valueStart);
		}
	}

	bool IsSafePngPath(std::string_view a_path)
	{
		if (!StartsWithIgnoreCase(a_path, kTextureRoot) || !EndsWithIgnoreCase(a_path, ".png")) {
			return false;
		}
		if (a_path.find("..") != std::string_view::npos || a_path.find('\\') != std::string_view::npos || a_path.find(':') != std::string_view::npos) {
			return false;
		}
		return std::all_of(a_path.begin(), a_path.end(), [](unsigned char a_char) {
			return a_char >= 0x20 && a_char <= 0x7E;
		});
	}

	void LogRejectedImage(std::string_view a_bookId, std::string_view a_source, std::string_view a_reason)
	{
		logger::warn("Iron Soul dynamic book: ignored image bookId={} source='{}' reason={}", a_bookId, a_source, a_reason);
	}

	std::vector<ImageReference> ParsePngImages(std::string_view a_bookId, std::string_view a_html)
	{
		std::vector<ImageReference> images;
		std::size_t scan = 0;
		bool limitLogged = false;

		while (scan < a_html.size()) {
			const std::size_t tagStart = FindIgnoreCase(a_html, "<img", scan);
			if (tagStart == std::string_view::npos) {
				break;
			}

			const std::size_t tagEnd = a_html.find('>', tagStart + 4);
			if (tagEnd == std::string_view::npos) {
				LogRejectedImage(a_bookId, a_html.substr(tagStart), "unterminated-tag");
				break;
			}

			const std::string_view tag = a_html.substr(tagStart, tagEnd - tagStart + 1);
			const auto source = ExtractImageSource(tag);
			if (!source) {
				LogRejectedImage(a_bookId, tag, "missing-src");
				scan = tagEnd + 1;
				continue;
			}
			if (!StartsWithIgnoreCase(*source, kImagePrefix)) {
				LogRejectedImage(a_bookId, *source, "unsupported-url");
				scan = tagEnd + 1;
				continue;
			}

			const std::string_view sourcePath = source->substr(kImagePrefix.size());
			if (!IsSafePngPath(sourcePath)) {
				LogRejectedImage(a_bookId, *source, "only-relative-textures-png-supported");
				scan = tagEnd + 1;
				continue;
			}

			const std::string url{ *source };
			const bool duplicate = std::any_of(images.begin(), images.end(), [&url](const ImageReference& a_image) {
				return EqualsIgnoreCase(a_image.url, url);
			});
			if (duplicate) {
				scan = tagEnd + 1;
				continue;
			}
			if (images.size() >= kMaxImages) {
				if (!limitLogged) {
					LogRejectedImage(a_bookId, *source, "image-limit-reached");
					limitLogged = true;
				}
				scan = tagEnd + 1;
				continue;
			}

			images.push_back({ std::string(sourcePath), url });
			scan = tagEnd + 1;
		}

		return images;
	}

	fs::path DynamicBookPath(std::string_view a_bookId)
	{
		return IronSoul::PathUtil::GetIronSoulPluginDir() / (std::string(a_bookId) + ".txt");
	}

	std::string DynamicBookDisplayPath(std::string_view a_bookId)
	{
		return std::string(kDisplayRoot) + std::string(a_bookId) + ".txt";
	}

	std::string BuildUnavailableText(std::string_view a_status, std::string_view a_displayPath)
	{
		return "<font face='$EverywhereFont' size='15'>Iron Soul dynamic book unavailable.</font>\n\n"
			"<font face='$EverywhereFont' size='15'>" + std::string(a_status) + " file:</font>\n"
			"<font face='$EverywhereFont' size='15'>" + std::string(a_displayPath) + "</font>\n";
	}

	std::optional<std::string> ParseMarkerOnlyText(std::string_view a_text, bool a_logMalformed, std::uint32_t a_formId = 0)
	{
		const std::string text = TrimCopy(a_text);
		if (!text.starts_with(kMarkerPrefix)) {
			return std::nullopt;
		}
		if (text.size() <= kMarkerPrefix.size() || text.back() != ']') {
			if (a_logMalformed) {
				if (a_formId != 0) {
					logger::warn("Iron Soul dynamic book: malformed marker on form 0x{:08X}", a_formId);
				} else {
					logger::warn("Iron Soul dynamic book: malformed marker");
				}
			}
			return std::nullopt;
		}

		const std::string bookId = text.substr(kMarkerPrefix.size(), text.size() - kMarkerPrefix.size() - 1);
		if (!IsValidBookId(bookId)) {
			if (a_logMalformed) {
				if (a_formId != 0) {
					logger::warn("Iron Soul dynamic book: invalid marker bookId='{}' form=0x{:08X}", bookId, a_formId);
				} else {
					logger::warn("Iron Soul dynamic book: invalid marker bookId='{}'", bookId);
				}
			}
			return std::nullopt;
		}
		return bookId;
	}

	void RefreshGeneratedBookIfNeeded(std::string_view a_bookId)
	{
		if (!EqualsIgnoreCase(a_bookId, kOghmaBookId)) {
			return;
		}

		const std::string guid = IronSoul::Identity::GetCurrentGuid();
		if (!IronSoul::JournalBook::DynamicBookRefreshOghma(guid)) {
			logger::warn("Iron Soul dynamic book: failed to refresh generated Oghma text before initial render guid={}", guid);
		}
	}

	std::string ReadTextForDisplay(std::string_view a_bookId)
	{
		const std::string bookId = TrimCopy(a_bookId);
		if (!IsValidBookId(bookId)) {
			logger::warn("Iron Soul dynamic book: invalid book id '{}'", bookId);
			return BuildUnavailableText("Invalid", DynamicBookDisplayPath("invalid"));
		}

		const fs::path path = DynamicBookPath(bookId);
		std::ifstream in(path, std::ios::in | std::ios::binary);
		if (!in.is_open()) {
			logger::warn("Iron Soul dynamic book: missing file bookId={} path={}", bookId, path.string());
			return BuildUnavailableText("Missing", DynamicBookDisplayPath(bookId));
		}

		std::ostringstream buffer;
		buffer << in.rdbuf();
		std::string text = buffer.str();
		const std::string trimmed = TrimCopy(text);
		if (trimmed == kEmptySentinel) {
			return " ";
		}
		if (trimmed.empty()) {
			logger::warn("Iron Soul dynamic book: empty file bookId={} path={}", bookId, path.string());
			return BuildUnavailableText("Empty", DynamicBookDisplayPath(bookId));
		}
		return text;
	}

	std::string ResolveTextForDisplay(std::string_view a_bookId)
	{
		RefreshGeneratedBookIfNeeded(a_bookId);
		return ReadTextForDisplay(a_bookId);
	}

	std::optional<std::string> ReadDynamicBookId(RE::TESObjectBOOK* a_book)
	{
		if (!a_book) {
			return std::nullopt;
		}

		RE::BSString description;
		a_book->GetDescription(description, a_book);
		return ParseMarkerOnlyText(description.c_str(), true, a_book->GetFormID());
	}

	std::optional<std::string> ReadDynamicBookIdFromDescriptionOrBook(std::string_view a_description, RE::TESObjectBOOK* a_book)
	{
		if (auto bookId = ParseMarkerOnlyText(a_description, false)) {
			return bookId;
		}
		return ReadDynamicBookId(a_book);
	}

	std::string BuildResolvedPayload(std::string_view a_bookId, std::string_view a_html)
	{
		return std::string(kResolvedMarkerPrefix) + std::string(a_bookId) + "]\n" + std::string(a_html);
	}

	bool HasRegisteredTexture(
		const RE::BSTArray<RE::BSScaleformExternalTexture>& a_textures,
		const ImageReference& a_image)
	{
		return std::any_of(a_textures.begin(), a_textures.end(), [&a_image](const RE::BSScaleformExternalTexture& a_texture) {
			const std::string_view path = a_texture.filePath.c_str();
			return EqualsIgnoreCase(path, a_image.url) || EqualsIgnoreCase(path, a_image.sourcePath);
		});
	}

	std::size_t RegisterPngTextures(RE::BookMenu& a_menu, std::string_view a_bookId, std::string_view a_html)
	{
		auto& textures = a_menu.GetRuntimeData().bookTextures;
		const std::vector<ImageReference> images = ParsePngImages(a_bookId, a_html);
		std::size_t added = 0;

		for (const ImageReference& image : images) {
			if (HasRegisteredTexture(textures, image)) {
				continue;
			}

			auto& texture = textures.emplace_back();
			// LoadPNG resolves the real texture path; Scaleform looks up the completed image URL.
			texture.filePath = RE::BSFixedString(image.sourcePath.c_str());
			if (!texture.LoadPNG(RE::BSFixedString(image.sourcePath.c_str()))) {
				logger::warn("Iron Soul dynamic book: failed to load PNG bookId={} path={}", a_bookId, image.sourcePath);
				textures.pop_back();
				continue;
			}
			texture.filePath = RE::BSFixedString(image.url.c_str());
			++added;
		}

		if (InfoLoggingEnabled() && !images.empty()) {
			logger::info("Iron Soul dynamic book: prepared PNG images bookId={} discovered={} registered={}", a_bookId, images.size(), added);
		}
		return added;
	}

	enum class PreparationResult
	{
		kNotDynamic,
		kPrepared,
		kNotReady
	};

	PreparationResult PrepareOpenBookImages(std::optional<std::string_view> a_expectedBookId = std::nullopt)
	{
		auto* ui = RE::UI::GetSingleton();
		if (!ui) {
			return PreparationResult::kNotReady;
		}

		auto menu = ui->GetMenu<RE::BookMenu>();
		if (!menu) {
			return PreparationResult::kNotReady;
		}

		auto* targetBook = RE::BookMenu::GetTargetForm();
		if (!targetBook) {
			return PreparationResult::kNotReady;
		}

		auto bookId = ReadDynamicBookId(targetBook);
		if (!bookId) {
			return PreparationResult::kNotDynamic;
		}
		if (a_expectedBookId && !EqualsIgnoreCase(*bookId, *a_expectedBookId)) {
			logger::debug("Iron Soul dynamic book: active book id '{}' does not match refresh id '{}'", *bookId, *a_expectedBookId);
			return PreparationResult::kNotDynamic;
		}

		RegisterPngTextures(*menu, *bookId, ReadTextForDisplay(*bookId));
		return PreparationResult::kPrepared;
	}

	void PrepareBookMenuImagesForInitialShow(RE::BookMenu* a_menu)
	{
		if (!a_menu) {
			return;
		}

		auto* targetBook = RE::BookMenu::GetTargetForm();
		auto bookId = ReadDynamicBookId(targetBook);
		if (!bookId) {
			return;
		}

		RegisterPngTextures(*a_menu, *bookId, ReadTextForDisplay(*bookId));
	}

	bool TryReadSetBookTextArguments(RE::FxResponseArgsBase& a_args, std::string_view& a_text, bool& a_isNote)
	{
		RE::GFxValue* values = nullptr;
		const std::uint32_t valueCount = a_args.GetValues(&values);
		if (!values || valueCount < 3 || !values[1].IsString() || !values[2].IsBool()) {
			return false;
		}

		const char* text = values[1].GetString();
		if (!text) {
			return false;
		}

		a_text = text;
		a_isNote = values[2].GetBool();
		return true;
	}

	void SetBookTextHook(RE::GFxMovieView* a_movieView, const char* a_methodName, RE::FxResponseArgsBase& a_args)
	{
		auto* original = g_setBookTextInvoke;
		if (!original) {
			logger::error("Iron Soul dynamic book: SetBookText hook has no original target");
			return;
		}

		if (!a_methodName || std::strcmp(a_methodName, kSetBookTextMethod.data()) != 0 || !a_movieView) {
			original(a_movieView, a_methodName, a_args);
			return;
		}

		std::string_view description;
		bool isNote = false;
		if (!TryReadSetBookTextArguments(a_args, description, isNote)) {
			logger::warn("Iron Soul dynamic book: SetBookText arguments did not match the expected text/note shape");
			original(a_movieView, a_methodName, a_args);
			return;
		}

		const auto bookId = ReadDynamicBookIdFromDescriptionOrBook(description, RE::BookMenu::GetTargetForm());
		if (!bookId) {
			original(a_movieView, a_methodName, a_args);
			return;
		}

		auto* ui = RE::UI::GetSingleton();
		auto menu = ui ? ui->GetMenu<RE::BookMenu>() : nullptr;
		if (!menu) {
			logger::warn("Iron Soul dynamic book: initial synchronous render skipped bookId={} reason=book-menu-not-ready", *bookId);
			original(a_movieView, a_methodName, a_args);
			return;
		}

		try {
			const std::string text = ResolveTextForDisplay(*bookId);
			RegisterPngTextures(*menu, *bookId, text);
			const std::string payload = BuildResolvedPayload(*bookId, text);

			RE::GFxValue textValue;
			textValue.SetString(payload.c_str());
			RE::GFxValue noteValue;
			noteValue.SetBoolean(isNote);
			RE::FxResponseArgs<2> replacementArgs;
			replacementArgs.Add(textValue);
			replacementArgs.Add(noteValue);

			if (InfoLoggingEnabled()) {
				logger::info("Iron Soul dynamic book: resolved initial SetBookText bookId={} bytes={}", *bookId, text.size());
			}
			original(a_movieView, a_methodName, replacementArgs);
		} catch (const std::exception& e) {
			logger::warn("Iron Soul dynamic book: initial synchronous render failed bookId={} error={}", *bookId, e.what());
			original(a_movieView, a_methodName, a_args);
		} catch (...) {
			logger::warn("Iron Soul dynamic book: initial synchronous render failed bookId={} with an unknown error", *bookId);
			original(a_movieView, a_methodName, a_args);
		}
	}

	bool InstallSetBookTextHook()
	{
		if (!REL::Module::IsSE() && !REL::Module::IsAE()) {
			logger::warn("Iron Soul dynamic book: initial synchronous render unsupported runtime={}", REL::Module::get().version().string());
			return false;
		}

		REL::Relocation<std::uintptr_t> setBookTextCall{
			RELOCATION_ID(50123, 51054),
			REL::VariantOffset(0x314, 0x318, 0)
		};
		const std::uintptr_t callSite = setBookTextCall.address();
		const auto* instruction = reinterpret_cast<const std::uint8_t*>(callSite);
		if (!instruction || instruction[0] != 0xE8) {
			logger::warn(
				"Iron Soul dynamic book: initial synchronous render disabled runtime={} callSite=0x{:X} expected=E8 actual=0x{:02X}",
				REL::Module::get().version().string(),
				callSite,
				instruction ? instruction[0] : 0U);
			return false;
		}

		std::int32_t displacement = 0;
		std::memcpy(&displacement, instruction + 1, sizeof(displacement));
		const std::uintptr_t originalAddress = callSite + 5 + static_cast<std::intptr_t>(displacement);
		if (originalAddress == 0) {
			logger::warn(
				"Iron Soul dynamic book: initial synchronous render disabled runtime={} callSite=0x{:X} reason=null-original-target",
				REL::Module::get().version().string(),
				callSite);
			return false;
		}

		const auto original = SKSE::GetTrampoline().write_call<5>(callSite, SetBookTextHook);
		g_setBookTextInvoke = reinterpret_cast<FxDelegateInvoke_t>(original);
		if (!g_setBookTextInvoke) {
			logger::error("Iron Soul dynamic book: SetBookText hook install returned a null original target");
			return false;
		}
		if (original != originalAddress) {
			logger::warn(
				"Iron Soul dynamic book: SetBookText hook original target changed during install expected=0x{:X} actual=0x{:X}",
				originalAddress,
				original);
		}

		logger::info(
			"Iron Soul dynamic book: initial synchronous SetBookText hook installed runtime={} callSite=0x{:X} target=0x{:X}",
			REL::Module::get().version().string(),
			callSite,
			original);
		return true;
	}

	RE::UI_MESSAGE_RESULTS ProcessMessageHook(RE::BookMenu* a_menu, RE::UIMessage& a_message)
	{
		if (a_message.type == RE::UI_MESSAGE_TYPE::kShow || a_message.type == RE::UI_MESSAGE_TYPE::kReshow) {
			PrepareBookMenuImagesForInitialShow(a_menu);
		}
		return g_processMessage(a_menu, a_message);
	}

	void QueueOnePreparationRetry()
	{
		if (auto* task = SKSE::GetTaskInterface()) {
			task->AddTask([]() {
				PrepareOpenBookImages();
			});
		} else {
			logger::warn("Iron Soul dynamic book: task interface unavailable for Book Menu preparation retry");
		}
	}
}

	RE::BSEventNotifyControl DynamicBookSink::ProcessEvent(
		const RE::MenuOpenCloseEvent* a_event,
		RE::BSTEventSource<RE::MenuOpenCloseEvent>*)
	{
		if (!a_event || !a_event->opening || a_event->menuName != RE::BookMenu::MENU_NAME) {
			return RE::BSEventNotifyControl::kContinue;
		}

		if (PrepareOpenBookImages() == PreparationResult::kNotReady) {
			QueueOnePreparationRetry();
		}
		return RE::BSEventNotifyControl::kContinue;
	}

	void RegisterSinks()
	{
		if (g_sinkRegistered) {
			return;
		}

		auto* ui = RE::UI::GetSingleton();
		if (!ui) {
			logger::warn("Iron Soul dynamic book: UI singleton unavailable; image preparation disabled");
			return;
		}

		ui->AddEventSink<RE::MenuOpenCloseEvent>(&g_sink);
		g_sinkRegistered = true;
		logger::info("Iron Soul dynamic book: Book Menu sink registered");
	}

	void RegisterLifecycleHooks()
	{
		if (g_hooksRegistered) {
			return;
		}

		const bool setBookTextHookInstalled = InstallSetBookTextHook();

		REL::Relocation<std::uintptr_t> bookMenuVTable{ RE::VTABLE_BookMenu[0] };
		g_processMessage = reinterpret_cast<ProcessMessage_t>(
			bookMenuVTable.write_vfunc(0x4, ProcessMessageHook));

		g_hooksRegistered = true;
		logger::info("Iron Soul dynamic book: initial render hooks registered synchronousSetBookText={}", setBookTextHookInstalled);
	}

	bool RefreshOpen(std::string_view a_bookId)
	{
		const std::string bookId = TrimCopy(a_bookId);
		if (!IsValidBookId(bookId)) {
			logger::warn("Iron Soul dynamic book: refused live refresh for invalid book id '{}'", bookId);
			return false;
		}

		const PreparationResult preparation = PrepareOpenBookImages(bookId);
		if (preparation != PreparationResult::kPrepared) {
			if (InfoLoggingEnabled()) {
				logger::info("Iron Soul dynamic book: live refresh skipped bookId={} reason={}", bookId, preparation == PreparationResult::kNotReady ? "book-menu-not-ready" : "different-or-untagged-book");
			}
			return false;
		}

		auto* ui = RE::UI::GetSingleton();
		if (!ui) {
			return false;
		}
		auto menu = ui->GetMenu<RE::BookMenu>();
		if (!menu) {
			return false;
		}
		auto movie = menu->GetRuntimeData().book;
		auto* movieView = movie.get();
		if (!movieView) {
			if (InfoLoggingEnabled()) {
				logger::info("Iron Soul dynamic book: live refresh skipped bookId={} reason=inner-book-movie-not-ready", bookId);
			}
			return false;
		}

		const std::string text = ReadTextForDisplay(bookId);
		RE::GFxValue args[3];
		args[0].SetString(bookId.c_str());
		args[1].SetString(text.c_str());
		args[2].SetNumber(-1.0);

		RE::GFxValue result;
		if (!movieView->Invoke(kRefreshPath.data(), &result, args, 3)) {
			logger::warn("Iron Soul dynamic book: {} missing from inner book movie during live refresh bookId={}", kRefreshPath, bookId);
			return false;
		}
		if (result.IsBool() && !result.GetBool()) {
			if (InfoLoggingEnabled()) {
				logger::info("Iron Soul dynamic book: live refresh skipped bookId={} reason=swf-not-ready", bookId);
			}
			return false;
		}

		if (InfoLoggingEnabled()) {
			logger::info("Iron Soul dynamic book: live refresh applied bookId={}", bookId);
		}
		return true;
	}
}
