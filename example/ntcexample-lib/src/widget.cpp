// Copyright Pavel A. Lebedev 2020
// Distributed under the Boost Software License, Version 1.0.
// (See accompanying file LICENSE.md or copy at http://boost.org/LICENSE_1_0.txt)
// SPDX-License-Identifier: BSL-1.0

#include <ntcexample/widget.hpp>

#include <ntcexample/config.hpp>

#if HAVE_MM_CLMULEPI64_SI128
#include <smmintrin.h>
#include <wmmintrin.h>
#endif

namespace ntcexample
{
    widget operator*(widget w1,widget w2) noexcept
    {
#if HAVE_MM_CLMULEPI64_SI128
        return widget{std::uint64_t(_mm_extract_epi64(_mm_clmulepi64_si128(
            _mm_cvtsi64_si128(std::int64_t(w1.x())),
            _mm_cvtsi64_si128(std::int64_t(w2.x())),
        0),0))};
#else
        std::uint64_t r = 0;
        for(std::uint64_t m1=w1.x(),m2=w2.x();m2;m1<<=1,m2>>=1)
            if(m2&1)
                r ^= m1;
        return r;
#endif
    }
}
