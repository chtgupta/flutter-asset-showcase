# Asset Showcase

Asset Showcase is a Dart package that generates an HTML showcase for assets present in a specified directory. It provides a convenient way to visualize and interact with your assets in a web browser.

## Features

- Generates an HTML showcase for assets in a specified directory.
- Supports sorting assets by name or size.
- Supports filtering assets based on file extensions.
- Includes a search bar for quickly finding assets.
- Provides a responsive and interactive user interface.
- Easy to customize and integrate into your projects.

## Screenshots
![Screenshot 2024-05-08 at 1 36 13 PM](https://github.com/chtgupta/flutter-asset-showcase/assets/22120812/7e1503d0-0a0d-41d1-9216-25483cedcf2f)

## Installation

To use Asset Showcase in your Dart project, add it as a dev dependency in your `pubspec.yaml` file:

```yaml
dev_dependencies:
  asset_showcase: ^1.0.3
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

## Acknowledgments

Certain parts of the code present in this repository are written using generative AI. I wish to share the prompts that served as a journey to creating this package.

https://chat.openai.com/share/699a3978-6933-475d-a1d3-5c1a72f99e60

## Contributing

Contributions are welcome! If you encounter any issues or have suggestions for improvements, please feel free to open an issue or submit a pull request on GitHub.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
