import 'package:flutter/material.dart';

// Default values from the Flutter's TabBar.
const double _kTabHeight = 46.0;

class ButtonsTabBar extends StatefulWidget implements PreferredSizeWidget {
  ButtonsTabBar({
    Key? key,
    required this.tabs,
    this.controller,
    this.duration = 250,
    this.backgroundColor,
    this.unselectedBackgroundColor,
    this.decoration,
    this.unselectedDecoration,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.borderWidth = 0,
    this.borderColor = Colors.black,
    this.unselectedBorderColor = Colors.black,
    this.physics = const BouncingScrollPhysics(),
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 4),
    this.buttonMargin = const EdgeInsets.all(4),
    this.labelSpacing = 4.0,
    this.radius = 7.0,
    this.elevation = 0,
    this.height = _kTabHeight,
    this.center = false,
    this.onTap,
  }) : super(key: key) {
    assert(backgroundColor == null || decoration == null);
    assert(unselectedBackgroundColor == null || unselectedDecoration == null);
  }

  /// Typically a list of two or more [Tab] widgets.
  ///
  /// The length of this list must match the [controller]'s [TabController.length]
  /// and the length of the [TabBarView.children] list.
  final List<Widget> tabs;

  /// This widget's selection and animation state.
  ///
  /// If [TabController] is not provided, then the value of [DefaultTabController.of]
  /// will be used.
  final TabController? controller;

  /// The duration in milliseconds of the transition animation.
  final int duration;

  /// The background [Color] of the button on its selected state.
  ///
  /// If [Color] is not provided, [Theme.of(context).accentColor] is used.
  final Color? backgroundColor;

  /// The background [Color] of the button on its unselected state.
  ///
  /// If [Color] is not provided, [Colors.grey[300]] is used.
  final Color? unselectedBackgroundColor;

  /// The [BoxDecoration] of the button on its selected state.
  ///
  /// If [BoxDecoration] is not provided, [backgroundColor] is used.
  final BoxDecoration? decoration;

  /// The [BoxDecoration] of the button on its unselected state.
  ///
  /// If [BoxDecoration] is not provided, [unselectedBackgroundColor] is used.
  final BoxDecoration? unselectedDecoration;

  /// The [TextStyle] of the button's [Text] on its selected state. The color provided
  /// on the TextStyle will be used for the [Icon]'s color.
  ///
  /// The default value is: [TextStyle(color: Colors.white)].
  final TextStyle? labelStyle;

  /// The [TextStyle] of the button's [Text] on its unselected state. The color provided
  /// on the TextStyle will be used for the [Icon]'s color.
  ///
  /// The default value is: [TextStyle(color: Colors.black)].
  final TextStyle? unselectedLabelStyle;

  /// The with of solid [Border] for each button. If no value is provided, the border
  /// is not drawn.
  ///
  /// The default value is: 0.
  final double borderWidth;

  /// The [Color] of solid [Border] for each button.
  ///
  /// The default value is: [Colors.black].
  final Color borderColor;

  /// The [Color] of solid [Border] for each button. If no value is provided, the value of
  /// [this.borderColor] is used.
  ///
  /// The default value is: [Colors.black].
  final Color unselectedBorderColor;

  /// The physics used for the [ScrollController] of the tabs list.
  ///
  /// The default value is [BouncingScrollPhysics].
  final ScrollPhysics physics;

  /// The [EdgeInsets] used for the [Padding] of the buttons' content.
  ///
  /// The default value is [EdgeInsets.symmetric(horizontal: 4)].
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

  /// The value of the [elevation] applied to each button.
  final double elevation;

  /// Override the default height.
  ///
  /// If no value is provided, the material height, 46.0, is used. If height is [null],
  /// the height is computed by summing the material height, 46, and the vertical values
  /// for [contentPadding] and [buttonMargin].
  final double? height;

  /// Center the tab buttons
  final bool center;

  /// An optional callback that's called when the [TabBar] is tapped.
  ///
  /// The callback is applied to the index of the tab where the tap occurred.
  ///
  /// This callback has no effect on the default handling of taps. It's for
  /// applications that want to do a little extra work when a tab is tapped,
  /// even if the tap doesn't change the [TabController]'s index. [TabBar] onTap
  /// callbacks should not make changes to the [TabController] since that would
  /// interfere with the default tap handler.
  final void Function(int)? onTap;

  @override
  Size get preferredSize {
    return Size.fromHeight(height ??
        (_kTabHeight + contentPadding.vertical + buttonMargin.vertical));
  }

  @override
  _ButtonsTabBarState createState() => _ButtonsTabBarState();
}

class _ButtonsTabBarState extends State<ButtonsTabBar>
    with TickerProviderStateMixin {
  TabController? _controller;

  ScrollController _scrollController = new ScrollController();

  late AnimationController _animationController;

  late List<GlobalKey> _tabKeys;
  GlobalKey _tabsContainerKey = GlobalKey();
  GlobalKey _tabsParentKey = GlobalKey();

  int _currentIndex = 0;
  int _prevIndex = -1;
  int _aniIndex = 0;
  double _prevAniValue = 0;

  // check the direction of the text LTR or RTL
  late bool _textLTR;

  EdgeInsets _centerPadding = EdgeInsets.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        ?.addPostFrameCallback((_) => _getCenterPadding(context));

    _tabKeys = widget.tabs.map((Widget tab) => GlobalKey()).toList();

    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.duration));

    // so the buttons start in their "final" state (color)
    _animationController.value = 1.0;
    _animationController.addListener(() {
      setState(() {});
    });
  }

  void _updateTabController() {
    final TabController? newController =
        widget.controller ?? DefaultTabController.of(context);
    assert(() {
      if (newController == null) {
        throw FlutterError('No TabController for ${widget.runtimeType}.\n'
            'When creating a ${widget.runtimeType}, you must either provide an explicit '
            'TabController using the "controller" property, or you must ensure that there '
            'is a DefaultTabController above the ${widget.runtimeType}.\n'
            'In this case, there was neither an explicit controller nor a default controller.');
      }
      return true;
    }());

    if (newController == _controller) return;

    if (_controllerIsValid) {
      _controller?.animation!.removeListener(_handleTabAnimation);
      _controller?.removeListener(_handleController);
    }
    _controller = newController;
    _controller?.animation!.addListener(_handleTabAnimation);
    _controller?.addListener(_handleController);
    _currentIndex = _controller!.index;
  }

  // If the TabBar is rebuilt with a new tab controller, the caller should
  // dispose the old one. In that case the old controller's animation will be
  // null and should not be accessed.
  bool get _controllerIsValid => _controller?.animation != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(debugCheckHasMaterial(context));
    _updateTabController();
  }

  @override
  void didUpdateWidget(ButtonsTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _updateTabController();
    }

    if (widget.tabs.length > oldWidget.tabs.length) {
      final int delta = widget.tabs.length - oldWidget.tabs.length;
      _tabKeys.addAll(List<GlobalKey>.generate(delta, (int n) => GlobalKey()));
    } else if (widget.tabs.length < oldWidget.tabs.length) {
      _tabKeys.removeRange(widget.tabs.length, oldWidget.tabs.length);
    }
  }

  void _handleController() {
    if (_controller!.indexIsChanging) {
      // update highlighted index when controller index is changing
      _goToIndex(_controller!.index);
    }
  }

  @override
  void dispose() {
    if (_controllerIsValid) {
      _controller!.animation!.removeListener(_handleTabAnimation);
      _controller!.removeListener(_handleController);
    }
    _controller = null;
    _scrollController.dispose();
    super.dispose();
  }

  _getCenterPadding(BuildContext context) {
    // get the screen width. This is used to check if we have an element off screen
    final RenderBox tabsParent =
        _tabsParentKey.currentContext!.findRenderObject() as RenderBox;
    final double screenWidth = tabsParent.size.width;

    RenderBox renderBox =
        _tabKeys.first.currentContext?.findRenderObject() as RenderBox;
    double size = renderBox.size.width;
    final double left = (screenWidth - size) / 2;

    renderBox = _tabKeys.last.currentContext?.findRenderObject() as RenderBox;
    size = renderBox.size.width;
    final double right = (screenWidth - size) / 2;
    _centerPadding = EdgeInsets.only(left: left, right: right);
  }

  Widget _buildButton(
    int index,
    Tab tab,
  ) {
    final double animationValue;
    if (index == _currentIndex)
      animationValue = _animationController.value;
    else if (index == _prevIndex)
      animationValue = 1 - _animationController.value;
    else
      animationValue = 0;

    final TextStyle? textStyle = TextStyle.lerp(
        widget.unselectedLabelStyle ?? TextStyle(color: Colors.black),
        widget.labelStyle ?? TextStyle(color: Colors.white),
        animationValue);
    final Color? borderColor = Color.lerp(
        widget.unselectedBorderColor, widget.borderColor, animationValue);
    final Color foregroundColor = textStyle?.color ?? Colors.black;

    final BoxDecoration? boxDecoration = BoxDecoration.lerp(
        BoxDecoration(
          color: widget.unselectedDecoration?.color ??
              widget.unselectedBackgroundColor ??
              Colors.grey[300],
          boxShadow: widget.unselectedDecoration?.boxShadow,
          gradient: widget.unselectedDecoration?.gradient,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
        BoxDecoration(
          color: widget.decoration?.color ??
              widget.backgroundColor ??
              Theme.of(context).colorScheme.secondary,
          boxShadow: widget.decoration?.boxShadow,
          gradient: widget.decoration?.gradient,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
        animationValue);

    if (index == 0) {
      //
    } else if (index == widget.tabs.length - 1) {
      //
    }

    return Padding(
      key: _tabKeys[index],
      // padding for the buttons
      padding: widget.buttonMargin,
      child: TextButton(
        onPressed: () {
          _controller?.animateTo(index);
          if (widget.onTap != null) widget.onTap!(index);
        },
        style: TextButton.styleFrom(
          elevation: widget.elevation,
          minimumSize: Size.fromWidth(48),
          padding: const EdgeInsets.all(0.0),
          textStyle: textStyle,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            side: (widget.borderWidth == 0)
                ? BorderSide.none
                : BorderSide(
                    color: borderColor ?? Colors.black,
                    width: widget.borderWidth,
                    style: BorderStyle.solid,
                  ),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        ),
        child: Ink(
          decoration: boxDecoration,
          child: Container(
            padding: widget.contentPadding,
            alignment: Alignment.center,
            child: Row(
              children: <Widget>[
                tab.icon != null
                    ? IconTheme.merge(
                        data: IconThemeData(size: 24.0, color: foregroundColor),
                        child: tab.icon!)
                    : Container(),
                SizedBox(
                  width: tab.icon == null ||
                          (tab.text == null && tab.child == null)
                      ? 0
                      : widget.labelSpacing,
                ),
                tab.text != null
                    ? Text(
                        tab.text!,
                        style: textStyle,
                      )
                    : (tab.child ?? Container())
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      if (_controller!.length != widget.tabs.length) {
        throw FlutterError(
            "Controller's length property (${_controller!.length}) does not match the "
            "number of tabs (${widget.tabs.length}) present in TabBar's tabs property.");
      }
      return true;
    }());
    if (_controller!.length == 0) return Container(height: widget.height);

    _textLTR = Directionality.of(context).index == 1;
    return Opacity(
      // avoid showing the tabBar if centering was request and the centerPadding wasn't calculated yet
      opacity: (!widget.center || _centerPadding != EdgeInsets.zero) ? 1 : 0,
      child: AnimatedBuilder(
        animation: _animationController,
        key: _tabsParentKey,
        builder: (context, child) => SizedBox(
          key: _tabsContainerKey,
          height: widget.preferredSize.height,
          child: ListView.builder(
            itemCount: widget.tabs.length,
            physics: widget.physics,
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: widget.center ? _centerPadding : EdgeInsets.zero,
            itemBuilder: (context, int index) =>
                _buildButton(index, widget.tabs[index] as Tab),
          ),
        ),
      ),
    );
  }

  // runs during the switching tabs animation
  _handleTabAnimation() {
    _aniIndex = ((_controller!.animation!.value > _prevAniValue)
            ? _controller!.animation!.value
            : _prevAniValue)
        .round();
    if (!_controller!.indexIsChanging && _aniIndex != _currentIndex) {
      _setCurrentIndex(_aniIndex);
    }
    _prevAniValue = _controller!.animation!.value;
  }

  _goToIndex(int index) {
    if (index != _currentIndex) {
      _setCurrentIndex(index);
      _controller?.animateTo(index);
    }
  }

  _setCurrentIndex(int index) {
    // change the index
    setState(() {
      _prevIndex = _currentIndex;
      _currentIndex = index;
    });
    _scrollTo(index); // scroll TabBar if needed
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
    final RenderBox tabsContainer =
        _tabsContainerKey.currentContext!.findRenderObject() as RenderBox;
    double screenWidth = tabsContainer.size.width;
    final tabsContainerPosition = tabsContainer.localToGlobal(Offset.zero).dx;
    // get the TabsContainer offset (for cases when padding is used)
    final tabsContainerOffset = Offset(-tabsContainerPosition, 0);

    // get the button we want to scroll to
    RenderBox renderBox =
        _tabKeys[index].currentContext?.findRenderObject() as RenderBox;
    // get its size
    double size = renderBox.size.width;
    // and position
    double position = renderBox.localToGlobal(tabsContainerOffset).dx;

    // this is how much the button is away from the center of the screen and how much we must scroll to get it into place
    double offset = (position + size / 2) - screenWidth / 2;

    // if the button is to the left of the middle
    if (offset < 0) {
      // get the first button
      renderBox = (_textLTR ? _tabKeys.first : _tabKeys.last)
          .currentContext
          ?.findRenderObject() as RenderBox;
      //// get the position of the first button of the TabBar
      position = renderBox.localToGlobal(tabsContainerOffset).dx;

      // if the offset pulls the first button away from the left side, we limit that movement so the first button is stuck to the left side
      if (!widget.center && position > offset) offset = position;
    } else {
      // if the button is to the right of the middle

      // get the last button
      renderBox = (_textLTR ? _tabKeys.last : _tabKeys.first)
          .currentContext
          ?.findRenderObject() as RenderBox;
      // get its position
      position = renderBox.localToGlobal(tabsContainerOffset).dx;
      // and size
      size = renderBox.size.width;

      // if the last button doesn't reach the right side, use it's right side as the limit of the screen for the TabBar
      if (position + size < screenWidth) screenWidth = position + size;

      // if the offset pulls the last button away from the right side limit, we reduce that movement so the last button is stuck to the right side limit
      if (!widget.center && position + size - offset < screenWidth)
        offset = position + size - screenWidth;
    }
    offset *= (_textLTR ? 1 : -1);

    // scroll the calculated ammount
    _scrollController.animateTo(offset + _scrollController.offset,
        duration: new Duration(milliseconds: widget.duration),
        curve: Curves.easeInOut);
  }
}
