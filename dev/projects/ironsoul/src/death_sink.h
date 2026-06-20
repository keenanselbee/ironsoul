#pragma once

#include <string>

namespace SKSE
{
    class SerializationInterface;
}

namespace IronSoul::DeathSink
{
    void RegisterLifecycleHooks();
    void HandleSerializationRevert();
    std::string DrainAnimaAwards();
}
