// Copyright Pavel A. Lebedev 2020
// Distributed under the Boost Software License, Version 1.0.
// (See accompanying file LICENSE.md or copy at http://boost.org/LICENSE_1_0.txt)
// SPDX-License-Identifier: BSL-1.0

#ifndef UUID_A7969802_0E75_4A4B_B089_5F25094B0C40
#define UUID_A7969802_0E75_4A4B_B089_5F25094B0C40

#include <ntcexample/export.h>

#include <boost/io/ios_state.hpp>

#include <cstdint>
#include <ostream>

namespace ntcexample
{
    class NTCEXAMPLE_LIB_EXPORT widget
    {
    public:
        explicit widget(std::uint64_t x) noexcept
            : x_{x}
        {}

        std::uint64_t x() const noexcept
        {
            return x_;
        }
    private:
        std::uint64_t x_;
    };

    inline std::ostream& operator<<(std::ostream& os,widget w)
    {
        boost::io::ios_flags_saver ifs{os};
        return os << "widget{" << std::hex << std::showbase << w.x() << '}';
    }

    NTCEXAMPLE_LIB_EXPORT widget operator*(widget w1,widget w2) noexcept;
}

#endif
