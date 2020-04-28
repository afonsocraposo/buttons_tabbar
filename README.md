# Buttons TabBar

<p>
  <img src="https://img.shields.io/badge/version-0.0.1%2B2-blue.svg" />
</p>

Open source Flutter package, tabbar where each tab indicator is a toggle button.

Made by Afonso Raposo.

See the full example [here](https://github.com/Afonsocraposo/buttons_tabbar/tree/master/example/example.dart)

## Screenshots

Install and import the package. Then just customize its parameters.

```yaml
dependencies:
  flutter:
    sdk: flutter
  buttons_tabbar: ^0.1.0+2
```

---

#### Default

![ButtonsTabBar screen](https://raw.githubusercontent.com/Afonsocraposo/buttons_tabbar/master/doc/screenshots/screen1.jpg)

![ButtonsTabBar screen animation](https://raw.githubusercontent.com/Afonsocraposo/buttons_tabbar/master/doc/screenshots/screen2.gif)

---

## Example

#### ButtonsTabBar - Example

![ButtonsTabBar - Example](https://raw.githubusercontent.com/Afonsocraposo/buttons_tabbar/master/doc/screenshots/example1.jpg)

```dart
DefaultTabController(
          length: ...,
          child: Column(
            children: <Widget>[
              ButtonsTabBar(
                unselectedBackgroundColor: Colors.grey[300],
                unselectedLabelStyle: TextStyle(color: Colors.black),
                labelStyle:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                tabs: ...,
              ),
              Expanded(
                child: TabBarView(
                  children: ...,
                ),
              ),
            ],
          ),
        )

```

---

## ButtonsTabBar Parameters

| Parameter                 | Type            | Description                                                                                                                               | Default                          |
| ------------------------- | --------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------- |
| **tabs**                  | `List<Widget>`  | The tabs to display. Typically a list of two or more `Tab` widgets.                                                                       | **`@required`**                  |
| controller                | `TabController` | This widget's selection and animation state.                                                                                              | `DefaultTabController.of`        |
| duration                  | `int`           | The duration in milliseconds of the transition animation.                                                                                 | `250`                            |
| backgroundColor           | `Color`         | The background color of the button on its selected state.                                                                                 | `Colors.blueAccent`              |
| unselectedBackgroundColor | `Color`         | The background color of the button on its unselected state.                                                                               | `Colors.grey`                    |
| labelStyle                | `TextStyle`     | The `TextStyle]` of the button's `Text` on its selected state. The color provided on the TextStyle will be used for the `Icon`'s color.   | `TextStyle(color: Colors.white)` |
| unselectedLabelStyle      | `TextStyle`     | The `TextStyle]` of the button's `Text` on its unselected state. The color provided on the TextStyle will be used for the `Icon`'s color. | `TextStyle(color: Colors.black)` |
| physics                   | `ScrollPhysics` | The physics used for the `ScrollController`of the tabs list.                                                                              | `BouncingScrollPhysics`          |
| contentPadding            | `EdgeInsets`    | The `EdgeInsets` used for the `Padding` of the buttons' content.                                                                          | `EdgeInsets.all(4)`              |
| buttonMargin              | `EdgeInsets`    | The `EdgeInsets` used for the `Margin` of the buttons.                                                                                    | `EdgeInsets.all(4)`              |
| labelSpacing              | `double`        | The spacing between the `Icon` and the `Text`. If only one of those is provided, no spacing is applied.                                   | `4.0`                            |
| radius                    | `double`        | The value of the `BorderRadius.circular` applied to each button.                                                                          | `7.0`                            |

---

## Future

If you have any suggestion or problem, let me know and I'll try to improve or fix it.

## Versioning

- v0.1.0+2 - 24 April 2020
- v0.1.0+1 - 24 April 2020

## License

GNU General Public License v3.0, see the [LICENSE.md](https://github.com/Afonsocraposo/buttons_tabbar/tree/master/LICENSE) file for details.
