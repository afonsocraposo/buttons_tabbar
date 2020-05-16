library buttons_tabbar;

import 'package:flutter/material.dart';

// Default values from the Flutter's TabBar.
const double _kTabHeight = 46.0;
const double _kTextAndIconTabHeight = 72.0;

class ButtonsTabBar extends StatefulWidget implements PreferredSizeWidget {
  ButtonsTabBar({
    Key key,
    @required this.tabs,
    this.controller,
    this.duration = 250,
    this.backgroundColor = Colors.blueAccent,
    this.unselectedBackgroundColor = Colors.grey,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.physics,
    this.contentPadding,
    this.buttonMargin,
    this.labelSpacing = 4.0,
    this.radius = 7.0,
  }) : super(key: key);

  /// Typically a list of two or more [Tab] widgets.
  ///
  /// The length of this list must match the [controller]'s [TabController.length]
  /// and the length of the [TabBarView.children] list.
  final List<Widget> tabs;

  /// This widget's selection and animation state.
  ///
  /// If [TabController] is not provided, then the value of [DefaultTabController.of]
  /// will be used.
  final TabController controller;

  /// The duration in milliseconds of the transition animation.
  final int duration;

  /// The background [Color] of the button on its selected state.
  final Color backgroundColor;

  /// The background [Color] of the button on its unselected state.
  final Color unselectedBackgroundColor;

  /// The [TextStyle] of the button's [Text] on its selected state. The color provided
  /// on the TextStyle will be used for the [Icon]'s color.
  ///
  /// The default value is: [TextStyle(color: Colors.white)].
  final TextStyle labelStyle;

  /// The [TextStyle] of the button's [Text] on its unselected state. The color provided
  /// on the TextStyle will be used for the [Icon]'s color.
  ///
  /// The default value is: [TextStyle(color: Colors.black)].
  final TextStyle unselectedLabelStyle;

  /// The physics used for the [ScrollController] of the tabs list.
  ///
  /// The default value is [BouncingScrollPhysics].
  final ScrollPhysics physics;

  /// The [EdgeInsets] used for the [Padding] of the buttons' content.
  ///
  /// The default value is [EdgeInsets.all(4)].
  final EdgeInsets contentPadding;

  /// The [EdgeInsets] used for the [Margin] of the buttons.
  ///
  /// The default value is [EdgeInsets.all(4)].
  final EdgeInsets buttonMargin;

  /// The spacing between the [Icon] and the [Text]. If only one of those is provided,
  /// no spacing is applied.
  final double labelSpacing;

  /// The value of the [BorderRadius.circular] applied to each button.
  final double radius;

  @override
  Size get preferredSize {
    for (Widget item in tabs) {
      if (item is Tab) {
        final Tab tab = item;
        if (tab.text != null && tab.icon != null)
          return Size.fromHeight(_kTextAndIconTabHeight);
      }
    }
    return Size.fromHeight(_kTabHeight);
  }

  @override
  _ButtonsTabBarState createState() => _ButtonsTabBarState();
}

class _ButtonsTabBarState extends State<ButtonsTabBar>
    with TickerProviderStateMixin {
  TabController _controller;

  ScrollController _scrollController = new ScrollController();
  ScrollPhysics _scrollPhysics;

  AnimationController _animationController;

  List<GlobalKey> _tabKeys;
  GlobalKey _tabsContainerKey = GlobalKey();

  Animation<Color> _colorTweenForegroundActivate;
  Animation<Color> _colorTweenForegroundDeactivate;
  Animation<Color> _colorTweenBackgroundActivate;
  Animation<Color> _colorTweenBackgroundDeactivate;

  Color _unselectedForegroundColor;
  Color _foregroundColor;

  TextStyle _unselectedLabelStyle;
  TextStyle _labelStyle;

  EdgeInsets _contentPadding;
  EdgeInsets _buttonMargin;

  int _currentIndex = 0;
  int _prevIndex = -1;
  int _aniIndex = 0;
  double _prevAniValue = 0;

  @override
  void initState() {
    super.initState();

    _tabKeys = widget.tabs.map((Widget tab) => GlobalKey()).toList();

    _scrollPhysics = widget.physics ?? BouncingScrollPhysics();

    _unselectedLabelStyle =
        widget.unselectedLabelStyle ?? TextStyle(color: Colors.black);
    _labelStyle = widget.labelStyle ?? TextStyle(color: Colors.white);

    _foregroundColor = _labelStyle.color ?? Colors.white;
    _unselectedForegroundColor = _unselectedLabelStyle.color ?? Colors.black;

    _contentPadding = widget.contentPadding ?? EdgeInsets.all(4);
    _buttonMargin = widget.buttonMargin ?? EdgeInsets.all(4);

    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.duration));
    _colorTweenBackgroundActivate = ColorTween(
            begin: widget.unselectedBackgroundColor,
            end: widget.backgroundColor)
        .animate(_animationController);
    _colorTweenBackgroundDeactivate = ColorTween(
            begin: widget.backgroundColor,
            end: widget.unselectedBackgroundColor)
        .animate(_animationController);
    _colorTweenForegroundActivate =
        ColorTween(begin: _unselectedForegroundColor, end: _foregroundColor)
            .animate(_animationController);
    _colorTweenForegroundDeactivate =
        ColorTween(begin: _foregroundColor, end: _unselectedForegroundColor)
            .animate(_animationController);
    // so the buttons start in their "final" state (color)
    _animationController.value = 1.0;
  }

  @override
  void dispose() {
    if (_controller != null) _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildButton(int index, Tab tab) {
    final TextStyle textStyle = (index == _currentIndex
        ? TextStyle.lerp(
            _unselectedLabelStyle, _labelStyle, _animationController.value)
        : (index == _prevIndex
            ? TextStyle.lerp(
                _labelStyle, _unselectedLabelStyle, _animationController.value)
            : _unselectedLabelStyle));
    return Container(
      key: _tabKeys[index],
      // padding for the buttons
      margin: _buttonMargin,
      child: FlatButton(
        padding: _contentPadding,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        // get the color of the button's background (dependent of its state)
        color: index == _currentIndex
            ? _colorTweenBackgroundActivate.value
            : (index == _prevIndex
                ? _colorTweenBackgroundDeactivate.value
                : widget.unselectedBackgroundColor),
        // make the button a rectangle with round corners
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(widget.radius)),
        onPressed: () {
          _goToIndex(index);
        },
        child: Row(
          children: <Widget>[
            tab.icon != null
                ? IconTheme.merge(
                    data: IconThemeData(
                        size: 24.0,
                        color: index == _currentIndex
                            ? _colorTweenForegroundActivate.value
                            : (index == _prevIndex
                                ? _colorTweenForegroundDeactivate.value
                                : _unselectedForegroundColor)),
                    child: tab.icon)
                : Container(),
            SizedBox(
              width: tab.icon == null || tab.text == null
                  ? 0
                  : widget.labelSpacing,
            ),
            tab.text != null
                ? Text(
                    tab.text,
                    style: textStyle,
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      _controller = widget.controller ?? DefaultTabController.of(context);
      // this will execute the function every time there's a swipe animation
      _controller.animation.addListener(_handleTabAnimation);
    }
    return AnimatedBuilder(
      animation: _colorTweenBackgroundActivate,
      builder: (context, child) => SizedBox(
        key: _tabsContainerKey,
        height: _kTabHeight,
        child: ListView.builder(
            physics: _scrollPhysics,
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.tabs.length,
            itemBuilder: (BuildContext context, int index) =>
                _buildButton(index, widget.tabs[index])),
      ),
    );
  }

  // runs during the switching tabs animation
  _handleTabAnimation() {
    _aniIndex = ((_controller.animation.value > _prevAniValue)
            ? _controller.animation.value
            : _prevAniValue)
        .round();
    if (!_controller.indexIsChanging && _aniIndex != _currentIndex) {
      setState(() {
        _setCurrentIndex(_aniIndex);
      });
    }
    _prevAniValue = _controller.animation.value;
  }

  _goToIndex(int index) {
    if (index != _currentIndex) {
      _setCurrentIndex(index);
      _controller.animateTo(index);
    }
  }

  _setCurrentIndex(int index) {
    setState(() {
      // change the index
      _prevIndex = _currentIndex;
      _currentIndex = index;
      _scrollTo(index); // scroll TabBar if needed
    });
    _triggerAnimation();
  }

  _triggerAnimation() {
    // reset the animation so it's ready to go
    _animationController.reset();

    // run the animation!
    _animationController.forward();
  }

  _scrollTo(int index) {
    // get the screen width. This is used to check if we have an element off screen
    RenderBox tabsContainer =
        _tabsContainerKey.currentContext.findRenderObject();
    double screenWidth = tabsContainer.size.width;

    // get the button we want to scroll to
    RenderBox renderBox = _tabKeys[index].currentContext.findRenderObject();
    // get its size
    double size = renderBox.size.width;
    // and position
    double position = renderBox.localToGlobal(Offset.zero).dx;

    // this is how much the button is away from the center of the screen and how much we must scroll to get it into place
    double offset = (position + size / 2) - screenWidth / 2;

    // if the button is to the left of the middle
    if (offset < 0) {
      // get the first button
      renderBox = _tabKeys[0].currentContext.findRenderObject();
      // get the position of the first button of the TabBar
      position = renderBox.localToGlobal(Offset.zero).dx;

      // if the offset pulls the first button away from the left side, we limit that movement so the first button is stuck to the left side
      if (position > offset) offset = position;
    } else {
      // if the button is to the right of the middle

      // get the last button
      renderBox = _tabKeys.last.currentContext.findRenderObject();
      // get its position
      position = renderBox.localToGlobal(Offset.zero).dx;
      // and size
      size = renderBox.size.width;

      // if the last button doesn't reach the right side, use it's right side as the limit of the screen for the TabBar
      if (position + size < screenWidth) screenWidth = position + size;

      // if the offset pulls the last button away from the right side limit, we reduce that movement so the last button is stuck to the right side limit
      if (position + size - offset < screenWidth) {
        offset = position + size - screenWidth;
      }
    }

    // scroll the calculated ammount
    _scrollController.animateTo(offset + _scrollController.offset,
        duration: new Duration(milliseconds: widget.duration),
        curve: Curves.easeInOut);
  }
}
