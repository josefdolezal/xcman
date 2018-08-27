`xcman` is an command line tool written in Swift for managing Xcode file templates and code snippets.

---

Move from this:

```bash
$ git clone https://github.com/me/my-templates.git
$ cd my-templates
$ ./install
  zsh: permission denied: ./install
$ chmod +x ./install
$ ./install
```

To this:

```bash
$ xcman templates install me/my-templates
````

## Install

<details open>
<summary>Brew</summary>

```bash
$ brew tap josefdolezal/formulae
$ brew install xcman
```
</details>

<details>
<summary>Compiling from source</summary>

```bash
$ git clone https://github.com/josefdolezal/xcman.git
$ cd xcman
$ swift build
```
</details>

## Usage

`xcman` supports managing of both file templates and code snippets. These functions are namespaced using `templates` and `snippets` subcommands. Run the tool with `--help` option to see documentation.

### Templates

Templates are managed using caching git repositories inside your home directory. For each installed group of templates, new folder is created inside Xcode templates directory. This new folder contains links to your fetched git folder.

Supported commands:

`install`

```bash
$ xcman templates install [--use-url] [--name <name>] <repo> 
```

Installs templates from given repository to Xcode. By default, given repository is interpreted as GitHub handle. If you would like to install from other source, use `--use-url` flag. Templates group name visible in Xcode may configured using `--name` option.

Examples:

```
# Install templates from GitHub repository with custom group name
$ xcman templates install --name "My Templates" me/my-templates

# Install templates from arbitrary url
$ xcman templates install --use-url https://gitlab.com/company/repo.git
```

`list`

```bash
$ xcman templates list
```

Lists all installed templates groups.

`remove`

```bash
$ xcman templates remove <group>
```

Removes given templates group from Xcode.

### Snippets

Snippets are managed similary as file templates using repository cache inside your home directory. Xcode currently does not support structured format for snippets, so the file system structure is flat.

`install`

```bash
$ xcman snippets install [--use-url] <repo>
```

Installs templates from given GitHub repository. By default, the repository argument is interpreted as GitHub handle. Use `--use-url` to install templates from arbitrary git repository.

## Dependencies

This tool is build on top following dependencies:

* [Commander](https://github.com/kylef/Commander), licensed under BSD 3-Clause

## License

This repository is licensed under [MIT](LICENSE).
