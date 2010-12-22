======================
ArgumentRewrap for VIM
======================

About
=====

ArgumentRewrap is a plugin for the VIM__ editor to split arbitrary calls with
multiple arguments into multiple lines.

__ http://vim.org


Examples
========

Think of a function call like this one::

    foo( bar, baz, blub );

Calling ArgumentRewrap on this function will split it into multiple lines with
correct indentation::

    foo(
        bar,
        baz,
        blub
    );

In a real world scenario you will most likely have to handle more complex
arguments, which might contain comma separated lists themselves::

    foo( [1,2,3], {a:"A", b:"B", c:"C"}, bar( some, other, function ) );

ArgumentWrap handles nested elements correctly and only rewraps the top level::

    foo(
        [1,2,3],
        {a:"A", b:"B", c:"C"},
        bar( some, other, function )
    );

If you want to rewrap nested elements simply select the corresponding line with
the cursor and rerun the ArgumentWrap function::

    foo(
        [1,2,3],
        {
            a:"A",
            b:"B",
            c:"C"
        },
        bar(
            some,
            other,
            function
        )
    );

The plugin function scans for the first occurrence of an opening parenthesis
"(", "[" and "{" which is followed by a comma. Therefore it is possible to
split entries with parenthesis preceding the actual argument list::

    foo["bar"] = someFunction( [1,2,3], arg2, arg3, arg4 );

The first brackets used for array access ``["bar"]`` are ignored, as they do
not contain a comma separated argument list::

    foo["bar"] = someFunction(
        [1,2,3],
        arg2,
        arg3,
        arg4
    );


Installation
============

Installing this plugin is realized by simply copying its files into the equally
named folders inside your ``.vim`` directory. If you are using Pathogen__ just
copy the folders of this plugin to a directory inside your ``bundle``
directory.

__ https://github.com/tpope/vim-pathogen

Keybinding
==========

The split functionality of the ArgumentRewrap is bound to the key combination
``<leader>s`` by default. To change the bound key combination simple change the
corresponding line inside the ``plugin/argumentrewrap.vim`` file.
