## Installation

To use Asset Showcase in your Dart project, add it as a dev dependency in your `pubspec.yaml` file:

```yaml
dev_dependencies:
  asset_showcase: ^1.0.4
```

Then, run `dart pub get` or `flutter pub get` to install the package.

## Usage

Once installed, you can use Asset Showcase to generate an HTML showcase for your assets. Just run it like any Dart package:

```bash
dart run asset_showcase
```

This will generate a showcase HTML file named `showcase.html` in the root directory of your project, showcasing assets from the `assets` directory.

## Command-line Options

Asset Showcase supports the following command-line options:

- `--assets`: Specifies the directory containing assets. Defaults to `'assets'`.
- `--output`: Specifies the output HTML file path. Defaults to `'showcase.html'`.

You can pass these options when running the Dart script, like so:

```bash
dart run asset_showcase --assets=path/to/assets --output=path/to/output.html
```
