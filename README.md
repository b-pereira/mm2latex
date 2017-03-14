# mm2latex
Docear MindMap to Latex XSLT

Based on `mm2wordml_utf8.xsl` by Naoki Nose and Eric Lavarde

# Usage
1. copy (or link) the `mm2latex.xsl` file into `<DOCEAR_HOME>/xslt/` (`DOCEAR_HOME` is probably `~/.docear` on linux)
2. restart docear
3. in docear `Tools->Export` with `Type: Latex Custom`

## Usage hints
- use latex packages `\usepackage{graphicx}` and `\usepackage[space]{grffile}` to support image files (with spaces in their path)

## supported attributes on root node
- **head-maxlevel** `int`: any node greater than this depth is itemized rather than creating a new structure level (e.g. chapter, section, ...)
- **droptext** `boolean`: itemized text is not output
- **image_directory** `string`: relative or absolute path from latex document to docear image directory (symlink advised, e.g. `mklink /D docear_images "..\...\_data\...\default_files\"`)

## supported attributes on nodes
- **NoHeading**: if attribute is present, the node and all childern are itemized
- **LastHeading**: if attribute is present, all children are itemized
- **image**: if attribute is present, the figure located at $image_directory/$image is inserted
- **image_width**: used for width of figure if present
- **drop**: do not output node and children

## styles instead of attributes
- If you only need to apply one attribute, you can apply a style with the same name instead.
  - e.g. create and apply a `drop` style which makes the text gray

## License
GPLv2
