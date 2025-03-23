Utility package that provides a seamless way to use box widgets sandwiched between slivers

## Features

1. Two widgets: `SliverPassthrough` and `BoxToSliverPassthrough`. First one turns sliver layout protocol to a box one,
   and the second one continues sliver layout where the first left off.
2. `SliverPassthrough` also provides `boxScrollOffset` in the form of `ValueListenable<double>`, which can be useful
   for `CustomPaint`, for example.

## Usage

```dart
CustomScrollView(
  slivers: [
    SliverPassthrough( // sliver
      minBoxExtent: .0, // extends scroll extent and prevents the box from squishing to 0, if necessary
      builder:
          (context, boxScrollOffset) => ColoredBox( // box
            color: Colors.red,
            child: BoxToSliverPassthrough( // sliver again, scrolled by the original CustomScrollView
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => SizedBox(),
                ),
              ),
            ),
          ),
    ),
  ],
)
```

## Community

Feel free to use [GitHub Discussions](https://github.com/NikolayNIK/sliver_passthrough/discussions) if you want:
- to ask a question to get help;
- to influence the project;
- to share ideas;
- to share interesting things this project allowed you to make;
- or to just discuss something related.

### Reporting bugs

If you encounter any bugs, feel free to use [GitHub Issue Tracker](https://github.com/NikolayNIK/sliver_passthrough/issues)
to search for an existing issue or to open up a new one.

### Contribution

If you have something to contribute to the package, feel free to send out a
[GitHub Pull Request](https://github.com/NikolayNIK/sliver_passthrough/pulls).

## License

All the source code is open
and distributed under the MIT license.
