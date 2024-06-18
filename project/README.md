# UNLWS Renderer
An app to write [UNLWS](https://s.ai/nlws/) texts using glyphs in SVG format

## Current progress
* Glyphs are imported and saved as SVGs through the Godot project folder.
* Binding point (BP) information is also stored in the SVGs. Currently it can only be added through code (through Godot or by editing the SVG directly).
* Basic text creation using commands.
* Basic undo-redo functionality.

## How to:
#### Import and save glyphs (wip)
1. If the glyph SVGs don't have binding point information yet:
	* Manually find the binding point positions and the angle (clockwise from the +X direction, in degrees) at which the binding point line ends.
	* Then choose how to add the binding point:
		* Add a command to the `.../Scripts/UNLWS_editor.gd` script (the file has examples).
		* Add the `<unlws-renderer:bp>` tag with the necessary attributes to the SVG code (see the example SVGs in `.../Images/Glyphs/`).
1. Put your SVGs in the Input folder (`.../Input/`).
	* One glyph per SVG file, the standard line width is `line-width:1`. Currently the file needs to have a `<g>` tag that contains everything else (all the elements that are drawn are its descendants, and all attributes that need to be saved belong to it or its descendants)
1. The SVGs are automatically saved to `.../Images/Glyphs/`  (some information is removed, like `id` tags, which will eventually need to be handled)
	* If a file exists in `.../Images/Glyphs/`, it'll be imported from there. To import from `.../Import` again, delete the old version.

#### Create texts (wip)
1. First import all the glyphs that you will use (and define their BPs).
1. Add commands to `.../Scripts/UNLWS_editor.gd` (examples are given) to instance the glyphs in the right positions.
1. The text is saved to `.../Output` as an SVG as soon as the project runs.

## Future work

### Goals (TODO)
* Import nearly any SVG as a glyph, potentally including animation, hover effects, calls to JS etc. (they won't be rendered here, but will still be there once a text is saved to SVG)
	* I'll need to pay extra attention to namespaces and IDs.
* Use a GUI to define what binding points a glyph has, how to form a scalar family from it etc.
* Enable writing texts quickly using the GUI and keyboard shortcuts.
	* Glyph search, so you can write the first letters of a glyph name (or a synonym) and select it from a list. (Currently, a glyph can be selected by writing its full name and pressing enter)
	* Select and edit multiple glyphs at once.
* Export (and import) texts from SVG files (using custom namespaces sparingly).
* Graph relaxation.

### How should ____ be handled?
* Cartouches
* Micrographs
