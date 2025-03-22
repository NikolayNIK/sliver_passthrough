import 'package:flutter/material.dart';
import 'package:sliver_passthrough/sliver_passthrough.dart';

void main() => runApp(const MaterialTableViewDemoApp());

const _title = 'sliver_passthrough demo';

class MaterialTableViewDemoApp extends StatelessWidget {
  const MaterialTableViewDemoApp({super.key});

  @override
  Widget build(BuildContext context) =>
      MaterialApp(
        title: _title,
        theme: _appTheme(Brightness.light),
        darkTheme: _appTheme(Brightness.dark),
        home: const DemoPage(),
      );

  ThemeData _appTheme(Brightness brightness) =>
      ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: brightness,
        ),
      );
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  var _scrollDirection = Axis.vertical;
  late TextDirection _textDirection;

  @override
  void initState() {
    super.initState();

    _textDirection =
        context.findAncestorWidgetOfExactType<Directionality>()!.textDirection;
  }

  @override
  Widget build(BuildContext context) =>
      Directionality(
        textDirection: _textDirection,
        child: Scaffold(
          appBar: AppBar(
            title: Text(_title),
            actions: [
              Tooltip(
                message:
                'Switch to ${_textDirection == TextDirection.ltr
                    ? 'right-to-left'
                    : 'left-to-right'} text direction',
                child: IconButton(
                  onPressed:
                      () =>
                      setState(
                            () =>
                        _textDirection =
                        _textDirection == TextDirection.ltr
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                      ),
                  icon: Icon(
                    _textDirection == TextDirection.ltr
                        ? Icons.format_textdirection_r_to_l
                        : Icons.format_textdirection_l_to_r,
                  ),
                ),
              ),
              Tooltip(
                message:
                'Switch to ${_scrollDirection == Axis.vertical
                    ? 'horizontal'
                    : 'vertical'} scrolling',
                child: IconButton(
                  onPressed:
                      () =>
                      setState(
                            () =>
                        _scrollDirection =
                        _scrollDirection == Axis.vertical
                            ? Axis.horizontal
                            : Axis.vertical,
                      ),
                  icon: Icon(
                    _scrollDirection == Axis.vertical
                        ? Icons.vertical_distribute
                        : Icons.horizontal_distribute,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: CustomScrollView(
              scrollDirection: _scrollDirection,
              slivers: [
                for (var i = 0; i < 8; i++)
                  SliverPassthrough(
                    builder:
                        (context, verticalOffset) =>
                        Placeholder(
                          child: BoxToSliverPassthrough(
                            sliver: SliverFixedExtentList(
                              delegate: SliverChildBuilderDelegate(
                                childCount: 32,
                                    (context, index) =>
                                    InkWell(
                                      onTap: () {},
                                      child: Align(
                                        alignment:
                                        Directionality.of(context) ==
                                            TextDirection.ltr
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(index.toString()),
                                        ),
                                      ),
                                    ),
                              ),
                              itemExtent: 56,
                            ),
                          ),
                        ),
                  ),
              ],
            ),
          ),
        ),
      );
}
