#include "pch.h"

#include "papyrus_text.h"
#include "papyrus_common.h"
#include "text_catalog.h"

namespace IronSoul::Papyrus::Text
{
namespace
{
	static std::string TextGet(RE::StaticFunctionTag*, std::string a_key)
	{
		return IronSoul::Text::Get(a_key);
	}

	static std::string TextFormat1(
		RE::StaticFunctionTag*,
		std::string a_key,
		std::string a_token1,
		std::string a_value1)
	{
		return IronSoul::Text::Format(a_key, { { a_token1, a_value1 } });
	}

	static std::string TextFormat2(
		RE::StaticFunctionTag*,
		std::string a_key,
		std::string a_token1,
		std::string a_value1,
		std::string a_token2,
		std::string a_value2)
	{
		return IronSoul::Text::Format(a_key, { { a_token1, a_value1 }, { a_token2, a_value2 } });
	}

	static std::string TextFormat3(
		RE::StaticFunctionTag*,
		std::string a_key,
		std::string a_token1,
		std::string a_value1,
		std::string a_token2,
		std::string a_value2,
		std::string a_token3,
		std::string a_value3)
	{
		return IronSoul::Text::Format(
			a_key,
			{ { a_token1, a_value1 }, { a_token2, a_value2 }, { a_token3, a_value3 } });
	}

	static std::string TextFormat4(
		RE::StaticFunctionTag*,
		std::string a_key,
		std::string a_token1,
		std::string a_value1,
		std::string a_token2,
		std::string a_value2,
		std::string a_token3,
		std::string a_value3,
		std::string a_token4,
		std::string a_value4)
	{
		return IronSoul::Text::Format(
			a_key,
			{
				{ a_token1, a_value1 },
				{ a_token2, a_value2 },
				{ a_token3, a_value3 },
				{ a_token4, a_value4 },
			});
	}
}

	void Register(RE::BSScript::IVirtualMachine* a_vm)
	{
		a_vm->RegisterFunction("TextGet", kScriptName, TextGet);
		a_vm->RegisterFunction("TextFormat1", kScriptName, TextFormat1);
		a_vm->RegisterFunction("TextFormat2", kScriptName, TextFormat2);
		a_vm->RegisterFunction("TextFormat3", kScriptName, TextFormat3);
		a_vm->RegisterFunction("TextFormat4", kScriptName, TextFormat4);
	}
}
