// Copyright Pavel A. Lebedev 2020
// Distributed under the Boost Software License, Version 1.0.
// (See accompanying file LICENSE.md or copy at http://boost.org/LICENSE_1_0.txt)
// SPDX-License-Identifier: BSL-1.0

#include <ntcexample/widget.hpp>

#include <iostream>

int main()
{
    using ntcexample::widget;
    std::cout << (widget{15}*widget{17}) << '\n';
}
