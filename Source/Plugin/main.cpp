#include "pch.h"

#include "plugin.h"
#include "PathUtil.h"
#include "PapyrusBindings.h"
#include "Config.h"
#include "DataStore.h"

namespace fs = std::filesystem;

namespace IronSoul
{
	// Minimal: set up plugin logging to SKSE log dir /IronSoul.log
	static void InitializeLogging()
	{
		auto dirOpt = logger::log_directory();
		if (!dirOpt) {
			util::report_and_fail("Iron Soul: logger::log_directory() returned empty");
		}

		const fs::path logDir = *dirOpt;
		std::error_code ec;
		fs::create_directories(logDir, ec);

#ifdef NDEBUG
		// Use the default plugin log name your docs expect.
		const fs::path logPath = logDir / "IronSoul.log";
		auto sink = std::make_shared<spdlog::sinks::basic_file_sink_mt>(logPath.string(), true);  // truncate on launch
		auto log = std::make_shared<spdlog::logger>("global log", std::move(sink));
		spdlog::set_default_logger(std::move(log));
#else
		// Debug: MSVC output
		auto sink = std::make_shared<spdlog::sinks::msvc_sink_mt>();
		auto log = std::make_shared<spdlog::logger>("global log", std::move(sink));
		spdlog::set_default_logger(std::move(log));
#endif

		spdlog::set_level(spdlog::level::info);
		spdlog::flush_on(spdlog::level::info);
	}

	static fs::path GetGameRoot()
	{
		wchar_t buf[MAX_PATH]{};
		DWORD len = GetModuleFileNameW(nullptr, buf, MAX_PATH);
		if (len == 0 || len >= MAX_PATH) {
			util::report_and_fail("Iron Soul: GetModuleFileNameW failed");
		}
		return fs::path{ buf }.parent_path();
	}

	static void EnsureDirectories()
	{
		// Where IronSoul.ini and the character journal live:
		// GameRoot/Data/SKSE/Plugins
		const fs::path pluginsDir = GetGameRoot() / L"Data" / L"SKSE" / L"Plugins";

		std::error_code ec;
		fs::create_directories(pluginsDir, ec);
		if (ec) {
			logger::warn("Iron Soul: could not create Data/SKSE/Plugins: {}", pluginsDir.string());
		}
	}
}

extern "C" DLLEXPORT bool SKSEAPI SKSEPlugin_Load(const SKSE::LoadInterface* a_skse)
{
	REL::Module::reset();

	IronSoul::InitializeLogging();

	logger::info("{} v{} loading...", Plugin::NAME, Plugin::VERSION.string());
	logger::info("Iron Soul: runtime = {}", a_skse->RuntimeVersion().string());

	// Keep it simple: just init SKSE + trampoline.
	SKSE::Init(a_skse);
	SKSE::AllocTrampoline(1 << 10);

	IronSoul::EnsureDirectories();

	IronSoul::Config::Load();
	// Phase 1 DataStore (.dat) init
	IronSoul::DataStore::Initialize();

	// Flush DataStore on save (most reliable session boundary)
	if (auto* ser = SKSE::GetSerializationInterface(); ser) {
		ser->SetUniqueID('ISDT');
		ser->SetSaveCallback([](SKSE::SerializationInterface*) {
			IronSoul::DataStore::FlushNow();
		});
	} else {
		logger::warn("Iron Soul: Serialization interface unavailable; save-flush disabled");
	}

	// Final best-effort flush on normal process exit
	std::atexit([]() {
		IronSoul::DataStore::Shutdown();
	});

	if (!IronSoul::Papyrus::Register()) {
		logger::critical("Iron Soul: Papyrus registration failed");
		return false;
	}

	logger::info("{} loaded successfully", Plugin::NAME);
	return true;
}
