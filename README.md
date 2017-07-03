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
- **label**: set a custom \label (if wanting to use a \ref within the text, as ooposed to the auto-generated ref when using arrow links in docear)
- **cite_info**: set the optional parameter for \cite, e.g. 'p. 19'
- **image**: if attribute is present, the figure located at $image_directory/$image is inserted
  - if no value is given, the node is assumed to contain latex code (the child nodes are then used as the caption)
- **image_width**: used for width of figure if present
- **drop**: do not output node and children
- **code**: output node in `lstlisting block`
- **latex**: output node without formatting
- **image_row**: images of child nodes are arranged in a row (image_width is mandatory for child nodes)
- **image_sideways**: rotate image 90 degrees
- **paragraphs**: do not itemize the node and its children, rather output the descendandts which are not headings as one block of text. Use a node with no text to create a new paragraph.
- **paragraphs_drop_self**: like _paragraphs_, but do not output the current node (only its children)

## styles instead of attributes
- If you only need to apply one attribute, you can apply a style with the same name instead.
  - e.g. create and apply a `drop` style which makes the text gray

## License
GPLv2
