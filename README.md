# owf-learn-aws #

This repository contains the [Open Water Foundation (OWF)](http://openwaterfoundation.org/) Amazon Web Services (AWS) learning resources,
which provides guidance for implementing AWS solutions.
The documentation is written for the layperson in order to encourage effective use of AWS.

See the deployed [OWF / Learn AWS](http://learn.openwaterfoundation.org/owf-learn-aws/) documentation.

## Repository Contents ##

The repository contains the following:

```text
.github/              Files specific to GitHub such as issue template.
.gitattributes        Typical Git configuration file.
.gitignore            Typical Git configuration file.
README.md             This file.
build-util/           Useful scripts to view, build, and deploy documentation.
mkdocs-project/       Typical MkDocs project for this documentation.
  mkdocs.yml          MkDocs configuration file for website.
  docs/               Folder containing source Markdown and other files for website.
  site/               Folder created by MkDocs containing the static website - ignored using .gitignore.
z-local-notes/        Local notes that will not be committed to repo,
                      useful to indicate local environment for Git for each developer.
```

## Development Environment ##

The development environment for contributing to this project requires installation of Python,
MkDocs, and Material MkDocs theme.  Python 3 has been used for development.

## Editing and Viewing Content ##

If the development environment is properly configured, edit and view content as follows:

1. Edit content in the `mkdocs-project/docs` folder and update `mkdocs-project/mkdocs.yml` as appropriate.
2. Run the `build-util/run-mkdocs-serve-8000.sh` script in Git Bash, Cygwin, Linux, or equivalent.
3. View content in a web browser using URL `http://localhost:8000`.

## License ##

The OWF Learn AWS website content and examples are licensed under the
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0).

## Contributing ##

Contribute to the documentation as follows:

1. Use GitHub repository issues to report minor issues.
2. Use GitHub pull requests.

## Maintainers ##

This repository is maintained by the [Open Water Foundation](http://openwaterfoundation.org/).
