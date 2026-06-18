#pragma once

#include <initializer_list>
#include <string>
#include <string_view>
#include <utility>

namespace IronSoul::Text
{
	using Replacement = std::pair<std::string_view, std::string_view>;

	void Load();
	std::string Get(std::string_view a_key);
	std::string Format(
		std::string_view a_key,
		std::initializer_list<Replacement> a_replacements);
}
