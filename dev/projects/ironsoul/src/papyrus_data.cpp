#include "pch.h"
#include "papyrus_data.h"
#include "papyrus_common.h"
#include "datastore.h"

namespace IronSoul::Papyrus::Data
{
namespace
{
    static int32_t DataGetInt(RE::StaticFunctionTag*, std::string a_key, int32_t a_fallback)
    {
        return IronSoul::DataStore::GetInt(a_key, a_fallback);
    }

    static void DataSetInt(RE::StaticFunctionTag*, std::string a_key, int32_t a_value)
    {
        if (!IronSoul::DataStore::SetInt(a_key, a_value)) {
            logger::warn("DataSetInt rejected (invalid key): key='{}' keyLen={}", a_key, a_key.size());
        }
    }

    static bool DataSetIntIfChanged(RE::StaticFunctionTag*, std::string a_key, int32_t a_value)
    {
        return IronSoul::DataStore::SetIntIfChanged(a_key, a_value);
    }

    static bool DataSetIntChecked(RE::StaticFunctionTag*, std::string a_key, int32_t a_value)
    {
        return IronSoul::DataStore::SetIntChecked(a_key, a_value);
    }

    static std::string DataGetString(RE::StaticFunctionTag*, std::string a_key, std::string a_fallback)
    {
        return IronSoul::DataStore::GetString(a_key, a_fallback);
    }

    static std::string DataGetCharacterData(RE::StaticFunctionTag*, std::string a_guid, std::string a_section)
    {
        return IronSoul::DataStore::GetCharacterData(a_guid, a_section);
    }

    static void DataSetString(RE::StaticFunctionTag*, std::string a_key, std::string a_value)
    {
        if (!IronSoul::DataStore::SetString(a_key, a_value)) {
            logger::warn(
                "DataSetString rejected (invalid key or value too long): key='{}' keyLen={} valueLen={}",
                a_key,
                a_key.size(),
                a_value.size());
        }
    }

    static bool DataSetStringIfChanged(RE::StaticFunctionTag*, std::string a_key, std::string a_value)
    {
        return IronSoul::DataStore::SetStringIfChanged(a_key, a_value);
    }

    static bool DataSetStringChecked(RE::StaticFunctionTag*, std::string a_key, std::string a_value)
    {
        return IronSoul::DataStore::SetStringChecked(a_key, a_value);
    }

    static bool DataHasKey(RE::StaticFunctionTag*, std::string a_key)
    {
        return IronSoul::DataStore::HasKey(a_key);
    }

    static void DataDeleteKey(RE::StaticFunctionTag*, std::string a_key)
    {
        IronSoul::DataStore::DeleteKey(a_key);
    }

    static int32_t DataDeleteKeysWithPrefix(RE::StaticFunctionTag*, std::string a_prefix)
    {
        return IronSoul::DataStore::DeleteKeysWithPrefix(a_prefix);
    }

    static bool DataStoreSizeWarningPending(RE::StaticFunctionTag*)
    {
        return IronSoul::DataStore::SizeWarningPending();
    }

    static bool DataStoreConsumeSizeWarning(RE::StaticFunctionTag*)
    {
        return IronSoul::DataStore::ConsumeSizeWarning();
    }

    static void DataFlushIfDirty(RE::StaticFunctionTag*)
    {
        IronSoul::DataStore::FlushIfDirty();
    }
}

    void Register(RE::BSScript::IVirtualMachine* a_vm)
    {
        a_vm->RegisterFunction("DataGetInt", kScriptName, DataGetInt);
        a_vm->RegisterFunction("DataSetInt", kScriptName, DataSetInt);
        a_vm->RegisterFunction("DataSetIntIfChanged", kScriptName, DataSetIntIfChanged);
        a_vm->RegisterFunction("DataSetIntChecked", kScriptName, DataSetIntChecked);
        a_vm->RegisterFunction("DataGetString", kScriptName, DataGetString);
        a_vm->RegisterFunction("DataGetCharacterData", kScriptName, DataGetCharacterData);
        a_vm->RegisterFunction("DataSetString", kScriptName, DataSetString);
        a_vm->RegisterFunction("DataSetStringIfChanged", kScriptName, DataSetStringIfChanged);
        a_vm->RegisterFunction("DataSetStringChecked", kScriptName, DataSetStringChecked);
        a_vm->RegisterFunction("DataHasKey", kScriptName, DataHasKey);
        a_vm->RegisterFunction("DataDeleteKey", kScriptName, DataDeleteKey);
        a_vm->RegisterFunction("DataDeleteKeysWithPrefix", kScriptName, DataDeleteKeysWithPrefix);
        a_vm->RegisterFunction("DataStoreSizeWarningPending", kScriptName, DataStoreSizeWarningPending);
        a_vm->RegisterFunction("DataStoreConsumeSizeWarning", kScriptName, DataStoreConsumeSizeWarning);
        a_vm->RegisterFunction("DataFlushIfDirty", kScriptName, DataFlushIfDirty);
    }
}
