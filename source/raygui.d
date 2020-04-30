/*******************************************************************************************
*
*   raygui v2.7 - A simple and easy-to-use immediate-mode gui library
*
*   DESCRIPTION:
*
*   raygui is a tools-dev-focused immediate-mode-gui library based on raylib but also
*   available as a standalone library, as long as input and drawing functions are provided.
*
*   Controls provided:
*
*   # Container/separators Controls
*       - WindowBox
*       - GroupBox
*       - Line
*       - Panel
*
*   # Basic Controls
*       - Label
*       - Button
*       - LabelButton   --> Label
*       - ImageButton   --> Button
*       - ImageButtonEx --> Button
*       - Toggle
*       - ToggleGroup   --> Toggle
*       - CheckBox
*       - ComboBox
*       - DropdownBox
*       - TextBox
*       - TextBoxMulti
*       - ValueBox      --> TextBox
*       - Spinner       --> Button, ValueBox
*       - Slider
*       - SliderBar     --> Slider
*       - ProgressBar
*       - StatusBar
*       - ScrollBar
*       - ScrollPanel
*       - DummyRec
*       - Grid
*
*   # Advance Controls
*       - ListView
*       - ColorPicker   --> ColorPanel, ColorBarHue
*       - MessageBox    --> Window, Label, Button
*       - TextInputBox  --> Window, Label, TextBox, Button
*
*   It also provides a set of functions for styling the controls based on its properties (size, color).
*
*   CONFIGURATION:
*
*   #define RAYGUI_IMPLEMENTATION
*       Generates the implementation of the library into the included file.
*       If not defined, the library is in header only mode and can be included in other headers
*       or source files without problems. But only ONE file should hold the implementation.
*
*   #define RAYGUI_STATIC (defined by default)
*       The generated implementation will stay private inside implementation file and all
*       internal symbols and functions will only be visible inside that file.
*
*   #define RAYGUI_STANDALONE
*       Avoid raylib.h header inclusion in this file. Data types defined on raylib are defined
*       internally in the library and input management and drawing functions must be provided by
*       the user (check library implementation for further details).
*
*   #define RAYGUI_SUPPORT_ICONS
*       Includes riconsdata.h header defining a set of 128 icons (binary format) to be used on
*       multiple controls and following raygui styles
*
*
*   VERSIONS HISTORY:
*       2.7 (20-Feb-2020) Added possible tooltips API
*       2.6 (09-Sep-2019) ADDED: GuiTextInputBox()
*                         REDESIGNED: GuiListView*(), GuiDropdownBox(), GuiSlider*(), GuiProgressBar(), GuiMessageBox()
*                         REVIEWED: GuiTextBox(), GuiSpinner(), GuiValueBox(), GuiLoadStyle()
*                         Replaced property INNER_PADDING by TEXT_PADDING, renamed some properties
*                         Added 8 new custom styles ready to use
*                         Multiple minor tweaks and bugs corrected
*       2.5 (28-May-2019) Implemented extended GuiTextBox(), GuiValueBox(), GuiSpinner()
*       2.3 (29-Apr-2019) Added rIcons auxiliar library and support for it, multiple controls reviewed
*                         Refactor all controls drawing mechanism to use control state
*       2.2 (05-Feb-2019) Added GuiScrollBar(), GuiScrollPanel(), reviewed GuiListView(), removed Gui*Ex() controls
*       2.1 (26-Dec-2018) Redesign of GuiCheckBox(), GuiComboBox(), GuiDropdownBox(), GuiToggleGroup() > Use combined text string
*                         Complete redesign of style system (breaking change)
*       2.0 (08-Nov-2018) Support controls guiLock and custom fonts, reviewed GuiComboBox(), GuiListView()...
*       1.9 (09-Oct-2018) Controls review: GuiGrid(), GuiTextBox(), GuiTextBoxMulti(), GuiValueBox()...
*       1.8 (01-May-2018) Lot of rework and redesign to align with rGuiStyler and rGuiLayout
*       1.5 (21-Jun-2017) Working in an improved styles system
*       1.4 (15-Jun-2017) Rewritten all GUI functions (removed useless ones)
*       1.3 (12-Jun-2017) Redesigned styles system
*       1.1 (01-Jun-2017) Complete review of the library
*       1.0 (07-Jun-2016) Converted to header-only by Ramon Santamaria.
*       0.9 (07-Mar-2016) Reviewed and tested by Albert Martos, Ian Eito, Sergio Martinez and Ramon Santamaria.
*       0.8 (27-Aug-2015) Initial release. Implemented by Kevin Gato, Daniel Nicolás and Ramon Santamaria.
*
*   CONTRIBUTORS:
*       Ramon Santamaria:   Supervision, review, redesign, update and maintenance...
*       Vlad Adrian:        Complete rewrite of GuiTextBox() to support extended features (2019)
*       Sergio Martinez:    Review, testing (2015) and redesign of multiple controls (2018)
*       Adria Arranz:       Testing and Implementation of additional controls (2018)
*       Jordi Jorba:        Testing and Implementation of additional controls (2018)
*       Albert Martos:      Review and testing of the library (2015)
*       Ian Eito:           Review and testing of the library (2015)
*       Kevin Gato:         Initial implementation of basic components (2014)
*       Daniel Nicolas:     Initial implementation of basic components (2014)
*
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2014-2020 Ramon Santamaria (@raysan5)
*
*   This software is provided "as-is", without any express or implied warranty. In no event
*   will the authors be held liable for any damages arising from the use of this software.
*
*   Permission is granted to anyone to use this software for any purpose, including commercial
*   applications, and to alter it and redistribute it freely, subject to the following restrictions:
*
*     1. The origin of this software must not be misrepresented; you must not claim that you
*     wrote the original software. If you use this software in a product, an acknowledgment
*     in the product documentation would be appreciated but is not required.
*
*     2. Altered source versions must be plainly marked as such, and must not be misrepresented
*     as being the original software.
*
*     3. This notice may not be removed or altered from any source distribution.
*
**********************************************************************************************/

import core.stdc.stdlib;
import raylib;

extern (C):

enum RAYGUI_VERSION = "2.6-dev";

// Define functions scope to be used internally (static) or externally (extern) to the module including this file

// Functions just visible to module including this file

// Functions visible from other files (no name mangling of functions in C++)

// NOTE: By default any function declared in a C file is extern // Functions visible from other files

// We are building raygui as a Win32 shared library (.dll).

// We are using raygui as a Win32 shared library (.dll)

// Required for: malloc(), calloc(), free()

// Allow custom memory allocators

alias RAYGUI_MALLOC = malloc;

alias RAYGUI_CALLOC = calloc;

alias RAYGUI_FREE = free;

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------
enum NUM_CONTROLS = 16; // Number of standard controls
enum NUM_PROPS_DEFAULT = 16; // Number of standard properties
enum NUM_PROPS_EXTENDED = 8; // Number of extended properties

enum TEXTEDIT_CURSOR_BLINK_FRAMES = 20; // Text edit controls cursor blink timming

//----------------------------------------------------------------------------------
// Types and Structures Definition
// NOTE: Some types are required for RAYGUI_STANDALONE usage
//----------------------------------------------------------------------------------

// Boolean type

// Vector2 type

// Vector3 type

// Color type, RGBA (32bit)

// Rectangle type

// TODO: Texture2D type is very coupled to raylib, mostly required by GuiImageButton()
// It should be redesigned to be provided by user

// OpenGL texture id
// Texture base width
// Texture base height
// Mipmap levels, 1 by default
// Data format (PixelFormat type)

// Font character info

// TODO: Font type is very coupled to raylib, mostly required by GuiLoadStyle()
// It should be redesigned to be provided by user

// Base size (default chars height)
// Number of characters
// Characters texture atlas
// Characters rectangles in texture
// Characters info data

// Style property
struct GuiStyleProp
{
    ushort controlId;
    ushort propertyId;
    int propertyValue;
}

// Gui control state
enum GuiControlState
{
    GUI_STATE_NORMAL = 0,
    GUI_STATE_FOCUSED = 1,
    GUI_STATE_PRESSED = 2,
    GUI_STATE_DISABLED = 3
}

// Gui control text alignment
enum GuiTextAlignment
{
    GUI_TEXT_ALIGN_LEFT = 0,
    GUI_TEXT_ALIGN_CENTER = 1,
    GUI_TEXT_ALIGN_RIGHT = 2
}

// Gui controls
enum GuiControl
{
    DEFAULT = 0,
    LABEL = 1, // LABELBUTTON
    BUTTON = 2, // IMAGEBUTTON
    TOGGLE = 3, // TOGGLEGROUP
    SLIDER = 4, // SLIDERBAR
    PROGRESSBAR = 5,
    CHECKBOX = 6,
    COMBOBOX = 7,
    DROPDOWNBOX = 8,
    TEXTBOX = 9, // TEXTBOXMULTI
    VALUEBOX = 10,
    SPINNER = 11,
    LISTVIEW = 12,
    COLORPICKER = 13,
    SCROLLBAR = 14,
    STATUSBAR = 15
}

// Gui base properties for every control
enum GuiControlProperty
{
    BORDER_COLOR_NORMAL = 0,
    BASE_COLOR_NORMAL = 1,
    TEXT_COLOR_NORMAL = 2,
    BORDER_COLOR_FOCUSED = 3,
    BASE_COLOR_FOCUSED = 4,
    TEXT_COLOR_FOCUSED = 5,
    BORDER_COLOR_PRESSED = 6,
    BASE_COLOR_PRESSED = 7,
    TEXT_COLOR_PRESSED = 8,
    BORDER_COLOR_DISABLED = 9,
    BASE_COLOR_DISABLED = 10,
    TEXT_COLOR_DISABLED = 11,
    BORDER_WIDTH = 12,
    TEXT_PADDING = 13,
    TEXT_ALIGNMENT = 14,
    RESERVED = 15
}

// Gui extended properties depend on control
// NOTE: We reserve a fixed size of additional properties per control

// DEFAULT properties
enum GuiDefaultProperty
{
    TEXT_SIZE = 16,
    TEXT_SPACING = 17,
    LINE_COLOR = 18,
    BACKGROUND_COLOR = 19
}

// Label
//typedef enum { } GuiLabelProperty;

// Button
//typedef enum { } GuiButtonProperty;

// Toggle / ToggleGroup
enum GuiToggleProperty
{
    GROUP_PADDING = 16
}

// Slider / SliderBar
enum GuiSliderProperty
{
    SLIDER_WIDTH = 16,
    SLIDER_PADDING = 17
}

// ProgressBar
enum GuiProgressBarProperty
{
    PROGRESS_PADDING = 16
}

// CheckBox
enum GuiCheckBoxProperty
{
    CHECK_PADDING = 16
}

// ComboBox
enum GuiComboBoxProperty
{
    COMBO_BUTTON_WIDTH = 16,
    COMBO_BUTTON_PADDING = 17
}

// DropdownBox
enum GuiDropdownBoxProperty
{
    ARROW_PADDING = 16,
    DROPDOWN_ITEMS_PADDING = 17
}

// TextBox / TextBoxMulti / ValueBox / Spinner
enum GuiTextBoxProperty
{
    TEXT_INNER_PADDING = 16,
    TEXT_LINES_PADDING = 17,
    COLOR_SELECTED_FG = 18,
    COLOR_SELECTED_BG = 19
}

// Spinner
enum GuiSpinnerProperty
{
    SPIN_BUTTON_WIDTH = 16,
    SPIN_BUTTON_PADDING = 17
}

// ScrollBar
enum GuiScrollBarProperty
{
    ARROWS_SIZE = 16,
    ARROWS_VISIBLE = 17,
    SCROLL_SLIDER_PADDING = 18,
    SCROLL_SLIDER_SIZE = 19,
    SCROLL_PADDING = 20,
    SCROLL_SPEED = 21
}

// ScrollBar side
enum GuiScrollBarSide
{
    SCROLLBAR_LEFT_SIDE = 0,
    SCROLLBAR_RIGHT_SIDE = 1
}

// ListView
enum GuiListViewProperty
{
    LIST_ITEMS_HEIGHT = 16,
    LIST_ITEMS_PADDING = 17,
    SCROLLBAR_WIDTH = 18,
    SCROLLBAR_SIDE = 19
}

// ColorPicker
enum GuiColorPickerProperty
{
    COLOR_SELECTOR_SIZE = 16,
    HUEBAR_WIDTH = 17, // Right hue bar width
    HUEBAR_PADDING = 18, // Right hue bar separation from panel
    HUEBAR_SELECTOR_HEIGHT = 19, // Right hue bar selector height
    HUEBAR_SELECTOR_OVERFLOW = 20 // Right hue bar selector overflow
}

//----------------------------------------------------------------------------------
// Global Variables Definition
//----------------------------------------------------------------------------------
// ...

//----------------------------------------------------------------------------------
// Module Functions Declaration
//----------------------------------------------------------------------------------

// State modification functions
void GuiEnable (); // Enable gui controls (global state)
void GuiDisable (); // Disable gui controls (global state)
void GuiLock (); // Lock gui controls (global state)
void GuiUnlock (); // Unlock gui controls (global state)
void GuiFade (float alpha); // Set gui controls alpha (global state), alpha goes from 0.0f to 1.0f
void GuiSetState (int state); // Set gui state (global state)
int GuiGetState (); // Get gui state (global state)

// Font set/get functions
void GuiSetFont (Font font); // Set gui custom font (global state)
Font GuiGetFont (); // Get gui custom font (global state)

// Style set/get functions
void GuiSetStyle (int control, int property, int value); // Set one style property
int GuiGetStyle (int control, int property); // Get one style property

// Tooltips set functions
void GuiEnableTooltip (); // Enable gui tooltips
void GuiDisableTooltip (); // Disable gui tooltips
void GuiSetTooltip (const(char)* tooltip); // Set current tooltip for display
void GuiClearTooltip (); // Clear any tooltip registered

// Container/separator controls, useful for controls organization
bool GuiWindowBox (Rectangle bounds, const(char)* title); // Window Box control, shows a window that can be closed
void GuiGroupBox (Rectangle bounds, const(char)* text); // Group Box control with text name
void GuiLine (Rectangle bounds, const(char)* text); // Line separator control, could contain text
void GuiPanel (Rectangle bounds); // Panel control, useful to group controls
Rectangle GuiScrollPanel (Rectangle bounds, Rectangle content, Vector2* scroll); // Scroll Panel control

// Basic controls set
void GuiLabel (Rectangle bounds, const(char)* text); // Label control, shows text
bool GuiButton (Rectangle bounds, const(char)* text); // Button control, returns true when clicked
bool GuiLabelButton (Rectangle bounds, const(char)* text); // Label button control, show true when clicked
bool GuiImageButton (Rectangle bounds, const(char)* text, Texture2D texture); // Image button control, returns true when clicked
bool GuiImageButtonEx (Rectangle bounds, const(char)* text, Texture2D texture, Rectangle texSource); // Image button extended control, returns true when clicked
bool GuiToggle (Rectangle bounds, const(char)* text, bool active); // Toggle Button control, returns true when active
int GuiToggleGroup (Rectangle bounds, const(char)* text, int active); // Toggle Group control, returns active toggle index
bool GuiCheckBox (Rectangle bounds, const(char)* text, bool checked); // Check Box control, returns true when active
int GuiComboBox (Rectangle bounds, const(char)* text, int active); // Combo Box control, returns selected item index
bool GuiDropdownBox (Rectangle bounds, const(char)* text, int* active, bool editMode); // Dropdown Box control, returns selected item
bool GuiSpinner (Rectangle bounds, const(char)* text, int* value, int minValue, int maxValue, bool editMode); // Spinner control, returns selected value
bool GuiValueBox (Rectangle bounds, const(char)* text, int* value, int minValue, int maxValue, bool editMode); // Value Box control, updates input text with numbers
bool GuiTextBox (Rectangle bounds, char* text, int textSize, bool editMode); // Text Box control, updates input text
bool GuiTextBoxMulti (Rectangle bounds, char* text, int textSize, bool editMode); // Text Box control with multiple lines
float GuiSlider (Rectangle bounds, const(char)* textLeft, const(char)* textRight, float value, float minValue, float maxValue); // Slider control, returns selected value
float GuiSliderBar (Rectangle bounds, const(char)* textLeft, const(char)* textRight, float value, float minValue, float maxValue); // Slider Bar control, returns selected value
float GuiProgressBar (Rectangle bounds, const(char)* textLeft, const(char)* textRight, float value, float minValue, float maxValue); // Progress Bar control, shows current progress value
void GuiStatusBar (Rectangle bounds, const(char)* text); // Status Bar control, shows info text
void GuiDummyRec (Rectangle bounds, const(char)* text); // Dummy control for placeholders
int GuiScrollBar (Rectangle bounds, int value, int minValue, int maxValue); // Scroll Bar control
Vector2 GuiGrid (Rectangle bounds, float spacing, int subdivs); // Grid control

// Advance controls set
int GuiListView (Rectangle bounds, const(char)* text, int* scrollIndex, int active); // List View control, returns selected list item index
int GuiListViewEx (Rectangle bounds, const(char*)* text, int count, int* focus, int* scrollIndex, int active); // List View with extended parameters
int GuiMessageBox (Rectangle bounds, const(char)* title, const(char)* message, const(char)* buttons); // Message Box control, displays a message
int GuiTextInputBox (Rectangle bounds, const(char)* title, const(char)* message, const(char)* buttons, char* text); // Text Input Box control, ask for text
Color GuiColorPicker (Rectangle bounds, Color color); // Color Picker control (multiple color controls)
Color GuiColorPanel (Rectangle bounds, Color color); // Color Panel control
float GuiColorBarAlpha (Rectangle bounds, float alpha); // Color Bar Alpha control
float GuiColorBarHue (Rectangle bounds, float value); // Color Bar Hue control

// Styles loading functions
void GuiLoadStyle (const(char)* fileName); // Load style file (.rgs)
void GuiLoadStyleDefault (); // Load style default over global style

/*
typedef GuiStyle (unsigned int *)
RAYGUIDEF GuiStyle LoadGuiStyle(const char *fileName);          // Load style from file (.rgs)
RAYGUIDEF void UnloadGuiStyle(GuiStyle style);                  // Unload style
*/

const(char)* GuiIconText (int iconId, const(char)* text); // Get text with icon id prepended (if supported)

// Gui icons functionality

// Get full icons data pointer
// Get icon bit data
// Set icon bit data

// Set icon pixel value
// Clear icon pixel value
// Check icon pixel value

// RAYGUI_H

/***********************************************************************************
*
*   RAYGUI IMPLEMENTATION
*
************************************************************************************/

// Required for: raygui icons data

// Required for: FILE, fopen(), fclose(), fprintf(), feof(), fscanf(), vsprintf()
// Required for: strlen() on GuiTextBox()

// Required for: va_list, va_start(), vfprintf(), va_end()

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------
//...

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
// Gui control property style color element

//----------------------------------------------------------------------------------
// Global Variables Definition
//----------------------------------------------------------------------------------

// Gui current font (WARNING: highly coupled to raylib)
// Gui lock state (no inputs processed)
// Gui element transpacency on drawing

// Global gui style array (allocated on heap by default)
// NOTE: In raygui we manage a single int array with all the possible style properties.
// When a new style is loaded, it loads over the global style... but default gui style
// could always be recovered with GuiLoadStyleDefault()

// Style loaded flag for lazy style initialization

// Tooltips required variables
// Gui tooltip currently active (user provided)
// Gui tooltips enabled

//----------------------------------------------------------------------------------
// Standalone Mode Functions Declaration
//
// NOTE: raygui depend on some raylib input and drawing functions
// To use raygui as standalone library, below functions must be defined by the user
//----------------------------------------------------------------------------------

// Input required functions
//-------------------------------------------------------------------------------

// -- GuiTextBox(), GuiTextBoxMulti(), GuiValueBox()
//-------------------------------------------------------------------------------

// Drawing required functions
//-------------------------------------------------------------------------------

// -- GuiColorPicker()
// -- GuiDropdownBox(), GuiScrollBar()
// -- GuiImageButtonEx()

// -- GuiTextBoxMulti()
//-------------------------------------------------------------------------------

// Text required functions
//-------------------------------------------------------------------------------
// -- GuiLoadStyleDefault()
// -- GetTextWidth(), GuiTextBoxMulti()
// -- GuiDrawText()

// -- GuiLoadStyle()
// -- GuiLoadStyle()
// -- GuiLoadStyle()
//-------------------------------------------------------------------------------

// raylib functions already implemented in raygui
//-------------------------------------------------------------------------------
// Returns a Color struct from hexadecimal value
// Returns hexadecimal value for a Color
// Color fade-in or fade-out, alpha goes from 0.0f to 1.0f
// Check if point is inside rectangle
// Formatting of text with variables to 'embed'
// Split text into multiple strings
// Get integer value from text

// Draw rectangle filled with color
// Draw rectangle outlines
// Draw rectangle vertical gradient
//-------------------------------------------------------------------------------

// RAYGUI_STANDALONE

//----------------------------------------------------------------------------------
// Module specific Functions Declaration
//----------------------------------------------------------------------------------
// Convert color data from HSV to RGB
// Convert color data from RGB to HSV

// Gui get text width using default font
// TODO: GetTextSize()

// TODO: Consider text icon width here???

// Get text bounds considering control bounds

// Consider TEXT_PADDING properly, depends on control type and TEXT_ALIGNMENT

// NOTE: ValueBox text value always centered, text padding applies to label

// TODO: Special cases (no label): COMBOBOX, DROPDOWNBOX, LISTVIEW (scrollbar?)
// More special cases (label side): CHECKBOX, SLIDER, VALUEBOX, SPINNER

// Get text icon if provided and move text cursor
// NOTE: We support up to 999 values for iconId

// Maybe we have an icon!

// Maximum length for icon value: 3 digits + '\0'

// Move text pointer after icon
// WARNING: If only icon provided, it could point to EOL character!

// Gui draw text using default font

// Vertical alignment for pixel perfect

// Check text for icon and move cursor

// Get text position depending on alignment and iconId
//---------------------------------------------------------------------------------

// NOTE: We get text size after icon been processed

// WARNING: If only icon provided, text could be pointing to eof character!

// Check guiTextAlign global variables

// NOTE: Make sure we get pixel-perfect coordinates,
// In case of decimals we got weird text positioning

//---------------------------------------------------------------------------------

// Draw text (with icon if available)
//---------------------------------------------------------------------------------

// NOTE: We consider icon height, probably different than text size

//---------------------------------------------------------------------------------

// Draw tooltip relatively to bounds

//static int tooltipFramesCounter = 0;  // Not possible gets reseted at second function call!

// Split controls text into multiple strings
// Also check for multiple columns (required by GuiToggleGroup())

//----------------------------------------------------------------------------------
// Gui Setup Functions Definition
//----------------------------------------------------------------------------------

// Enable gui global state

// Disable gui global state

// Lock gui global state

// Unlock gui global state

// Set gui controls alpha global state

// Set gui state (global state)

// Get gui state (global state)

// Set custom gui font
// NOTE: Font loading/unloading is external to raygui

// NOTE: If we try to setup a font but default style has not been
// lazily loaded before, it will be overwritten, so we need to force
// default style loading first

// Get custom gui font

// Set control style property value

// Default properties are propagated to all controls

// Get control style property value

// Enable gui tooltips

// Disable gui tooltips

// Set current tooltip for display

// Clear any tooltip registered

//----------------------------------------------------------------------------------
// Gui Controls Functions Definition
//----------------------------------------------------------------------------------

// Window Box control

// NOTE: This define is also used by GuiMessageBox() and GuiTextInputBox()

// Update control
//--------------------------------------------------------------------
// NOTE: Logic is directly managed by button
//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------

// Draw window base

// Draw window header as status bar

// Draw window close button

//--------------------------------------------------------------------

// Group Box control with text name

// Draw control
//--------------------------------------------------------------------

//--------------------------------------------------------------------

// Line control

// Draw control
//--------------------------------------------------------------------

// TODO: Consider text icon

// Draw line with embedded text label: "--- text --------------"

//--------------------------------------------------------------------

// Panel control

// Draw control
//--------------------------------------------------------------------

//--------------------------------------------------------------------

// Scroll Panel control

// Recheck to account for the other scrollbar being visible

// Calculate view area (area without the scrollbars)

// Clip view area to the actual content size

// TODO: Review!

// Update control
//--------------------------------------------------------------------

// Check button state

// Normalize scroll values

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------
// Draw background

// Save size of the scrollbar slider

// Draw horizontal scrollbar if visible

// Change scrollbar slider size to show the diff in size between the content width and the widget width

// Draw vertical scrollbar if visible

// Change scrollbar slider size to show the diff in size between the content height and the widget height

// Draw detail corner rectangle if both scroll bars are visible

// TODO: Consider scroll bars side

// Set scrollbar slider size back to the way it was before

// Draw scrollbar lines depending on current state

//--------------------------------------------------------------------

// Label control

// Update control
//--------------------------------------------------------------------
// ...
//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------

//--------------------------------------------------------------------

// Button control, returns true when clicked

// Update control
//--------------------------------------------------------------------

// Check button state

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------

//------------------------------------------------------------------

// Label button control

// NOTE: We force bounds.width to be all text

// Update control
//--------------------------------------------------------------------

// Check checkbox state

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------

//--------------------------------------------------------------------

// Image button control, returns true when clicked

// Image button control, returns true when clicked

// Update control
//--------------------------------------------------------------------

// Check button state

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------

//------------------------------------------------------------------

// Toggle Button control, returns true when active

// Update control
//--------------------------------------------------------------------

// Check toggle button state

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------

//--------------------------------------------------------------------

// Toggle Group control, returns toggled button index

// Get substrings items from text (items pointers)

// Check Box control, returns true when active

// Update control
//--------------------------------------------------------------------

// Check checkbox state

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------

//--------------------------------------------------------------------

// Combo Box control, returns selected item index

// Get substrings items from text (items pointers, lengths and count)

// Update control
//--------------------------------------------------------------------

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------
// Draw combo box main

// Draw selector using a custom button
// NOTE: BORDER_WIDTH and TEXT_ALIGNMENT forced values

//--------------------------------------------------------------------

// Dropdown Box control
// NOTE: Returns mouse click

// Get substrings items from text (items pointers, lengths and count)

// Check mouse button pressed

// Update control
//--------------------------------------------------------------------

// Check if mouse has been pressed or released outside limits

// Check if already selected item has been pressed again

// Check focused and selected item

// Update item rectangle y position for next item

// Item selected, change to editMode = false

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------

// Draw visible items

// Update item rectangle y position for next item

// TODO: Avoid this function, use icon instead or 'v'

//GuiDrawText("v", RAYGUI_CLITERAL(Rectangle){ bounds.x + bounds.width - GuiGetStyle(DROPDOWNBOX, ARROW_PADDING), bounds.y + bounds.height/2 - 2, 10, 10 },
//            GUI_TEXT_ALIGN_CENTER, Fade(GetColor(GuiGetStyle(DROPDOWNBOX, TEXT + (state*3))), guiAlpha));
//--------------------------------------------------------------------

// Text Box control, updates input text
// NOTE 1: Requires static variables: framesCounter
// NOTE 2: Returns if KEY_ENTER pressed (useful for data validation)

// Required for blinking cursor

// Update control
//--------------------------------------------------------------------

// Only allow keys in range [32..125]

// Delete text

// Check text alignment to position cursor properly

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------

// Draw blinking cursor

//--------------------------------------------------------------------

// Spinner control, returns selected value

// Update control
//--------------------------------------------------------------------

// Check spinner state

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------
// TODO: Set Spinner properties for ValueBox

// Draw value selector custom buttons
// NOTE: BORDER_WIDTH and TEXT_ALIGNMENT forced values

// Draw text label if provided

//--------------------------------------------------------------------

// Value Box control, updates input text with numbers
// NOTE: Requires static variables: framesCounter

// Required for blinking cursor

// Update control
//--------------------------------------------------------------------

// Only allow keys in range [48..57]

// Delete text

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------

// Draw blinking cursor
// NOTE: ValueBox internal text is always centered

// Draw text label if provided

//--------------------------------------------------------------------

// Text Box control with multiple lines

// Required for blinking cursor

// Cursor position, [x, y] values should be updated

// Update control
//--------------------------------------------------------------------

// Introduce characters

// TODO: Support Unicode inputs

// Delete characters

// Calculate cursor position considering text

// Exit edit mode

// Reset blinking cursor

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------

// Draw blinking cursor

//--------------------------------------------------------------------

// Slider control with pro parameters
// NOTE: Other GuiSlider*() controls use this one

// Slider

// SliderBar

// Update control
//--------------------------------------------------------------------

// Get equivalent value and slider position from mousePoint.x

// Slider
// SliderBar

// Bar limits check
// Slider

// SliderBar

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------

// Draw slider internal bar (depends on state)

// Draw left/right text if provided

// TODO: Consider text icon

// TODO: Consider text icon

//--------------------------------------------------------------------

// Slider control extended, returns selected value and has text

// Slider Bar control extended, returns selected value

// Progress Bar control extended, shows current progress value

// Update control
//--------------------------------------------------------------------

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------

// Draw slider internal progress bar (depends on state)

// Draw left/right text if provided

// TODO: Consider text icon

// TODO: Consider text icon

//--------------------------------------------------------------------

// Status Bar control

// Draw control
//--------------------------------------------------------------------

//--------------------------------------------------------------------

// Dummy rectangle control, intended for placeholding

// Update control
//--------------------------------------------------------------------

// Check button state

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------

//------------------------------------------------------------------

// Scroll Bar control
// TODO: I feel GuiScrollBar could be simplified...

// Is the scrollbar horizontal or vertical?

// The size (width or height depending on scrollbar type) of the spinner buttons

// Arrow buttons [<] [>] [∧] [∨]

// Actual area of the scrollbar excluding the arrow buttons

// Slider bar that moves     --[///]-----

// Normalize value

// Calculate rectangles for all of the components

// Make sure the slider won't get outside of the scrollbar

// Make sure the slider won't get outside of the scrollbar

// Update control
//--------------------------------------------------------------------

// Handle mouse wheel

// Normalize value

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------
// Draw the background
// Draw the scrollbar active area background

// Draw the slider bar

// Draw arrows

// Coordinates for <     0,1,2

// Coordinates for >     3,4,5

// Coordinates for ∧     6,7,8

// Coordinates for ∨     9,10,11

//--------------------------------------------------------------------

// List View control

// List View control with extended parameters

// Check if we need a scroll bar

// Define base item rectangle [0]

// Get items on the list

// Update control
//--------------------------------------------------------------------

// Check mouse inside list view

// Check focused and selected item

// Update item rectangle y position for next item

// Reset item rectangle y to [0]

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------
// Draw background

// Draw visible items

// Draw item selected

// Draw item focused

// Draw item normal

// Update item rectangle y position for next item

// Calculate percentage of visible items and apply same percentage to scrollbar

// Save default slider size
// Save default scroll speed
// Change slider size
// Change scroll speed

// Reset scroll speed to default
// Reset slider size to default

//--------------------------------------------------------------------

// Color Panel control

// HSV: Saturation
// HSV: Value

// Update control
//--------------------------------------------------------------------

// Calculate color from picker

// Get normalized value on x
// Get normalized value on y

// NOTE: Vector3ToColor() only available on raylib 1.8.1

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------

// Draw color picker: selector

//--------------------------------------------------------------------

// Color Bar Alpha control
// NOTE: Returns alpha value normalized [0..1]

// Update control
//--------------------------------------------------------------------

//selector.x = bounds.x + (int)(((alpha - 0)/(100 - 0))*(bounds.width - 2*GuiGetStyle(SLIDER, BORDER_WIDTH))) - selector.width/2;

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------

// Draw alpha bar: checked background

// Draw alpha bar: selector

//--------------------------------------------------------------------

// Color Bar Hue control
// NOTE: Returns hue value normalized [0..1]

// Update control
//--------------------------------------------------------------------

/*if (IsKeyDown(KEY_UP))
{
    hue -= 2.0f;
    if (hue <= 0.0f) hue = 0.0f;
}
else if (IsKeyDown(KEY_DOWN))
{
    hue += 2.0f;
    if (hue >= 360.0f) hue = 360.0f;
}*/

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------

// Draw hue bar:color bars

// Draw hue bar: selector

//--------------------------------------------------------------------

// TODO: Color GuiColorBarSat() [WHITE->color]
// TODO: Color GuiColorBarValue() [BLACK->color], HSV / HSL
// TODO: float GuiColorBarLuminance() [BLACK->WHITE]

// Color Picker control
// NOTE: It's divided in multiple controls:
//      Color GuiColorPanel(Rectangle bounds, Color color)
//      float GuiColorBarAlpha(Rectangle bounds, float alpha)
//      float GuiColorBarHue(Rectangle bounds, float value)
// NOTE: bounds define GuiColorPanel() size

//Rectangle boundsAlpha = { bounds.x, bounds.y + bounds.height + GuiGetStyle(COLORPICKER, BARS_PADDING), bounds.width, GuiGetStyle(COLORPICKER, BARS_THICK) };

//color.a = (unsigned char)(GuiColorBarAlpha(boundsAlpha, (float)color.a/255.0f)*255.0f);

// Message Box control

// Returns clicked button from buttons list, 0 refers to closed window button

// Draw control
//--------------------------------------------------------------------

//--------------------------------------------------------------------

// Text Input Box control, ask for text

// Used to enable text edit mode
// WARNING: No more than one GuiTextInputBox() should be open at the same time

// Draw control
//--------------------------------------------------------------------

// Draw message if available

//--------------------------------------------------------------------

// Grid control
// NOTE: Returns grid mouse-hover selected cell
// About drawing lines at subpixel spacing, simple put, not easy solution:
// https://stackoverflow.com/questions/4435450/2d-opengl-drawing-lines-that-dont-exactly-fit-pixel-raster

// Grid lines alpha amount

// Update control
//--------------------------------------------------------------------

//--------------------------------------------------------------------

// Draw control
//--------------------------------------------------------------------

// Draw vertical grid lines

// Draw horizontal grid lines

//----------------------------------------------------------------------------------
// Styles loading functions
//----------------------------------------------------------------------------------

// Load raygui style file (.rgs)

// Try reading the files as text file first

// Style property: p <control_id> <property_id> <property_value> <property_name>

// Style font: f <gen_font_size> <charmap_file> <font_file>

// Load characters from charmap file,
// expected '\n' separated list of integer values

// DEFAULT control

// If a DEFAULT property is loaded, it is propagated to all controls
// NOTE: All DEFAULT properties should be defined first in the file

// Font loading is highly dependant on raylib API to load font data and image
// TODO: Find some mechanism to support it in standalone mode

// Load custom font if available

// 0-Normal, 1-SDF

// Load font white rectangle

// Load font image parameters

// Load font recs data

// Load font chars info data

// Set font texture source rectangle to be used as white texture to draw shapes
// NOTE: This way, all gui can be draw using a single draw call

// Load style default over global style

// We set this variable first to avoid cyclic function calls
// when calling GuiSetStyle() and GuiGetStyle()

// Initialize default LIGHT style property values

// WARNING: Some controls use other values
// WARNING: Some controls use other values
// WARNING: Some controls use other values

// Initialize control-specific property values
// NOTE: Those properties are in default list but require specific values by control type

// Initialize extended property values
// NOTE: By default, extended property values are initialized to 0
// DEFAULT, shared by all controls
// DEFAULT, shared by all controls
// DEFAULT specific property
// DEFAULT specific property

// Initialize default font

// Get text with icon id prepended
// NOTE: Useful to add icons by name id (enum) instead of
// a number that can change between ricon versions

// Get full icons data pointer

// Load raygui icons file (.rgi)
// NOTE: In case nameIds are required, they can be requested with loadIconsName,
// they are returned as a guiIconsName[iconsCount][RICON_MAX_NAME_LENGTH],
// guiIconsName[]][] memory should be manually freed!

// Style File Structure (.rgi)
// ------------------------------------------------------
// Offset  | Size    | Type       | Description
// ------------------------------------------------------
// 0       | 4       | char       | Signature: "rGI "
// 4       | 2       | short      | Version: 100
// 6       | 2       | short      | reserved

// 8       | 2       | short      | Num icons (N)
// 10      | 2       | short      | Icons size (Options: 16, 32, 64) (S)

// Icons name id (32 bytes per name id)
// foreach (icon)
// {
//   12+32*i  | 32   | char       | Icon NameId
// }

// Icons data: One bit per pixel, stored as unsigned int array (depends on icon size)
// S*S pixels/32bit per unsigned int = K unsigned int per icon
// foreach (icon)
// {
//   ...   | K       | unsigned int | Icon Data
// }

// Read icons data directly over guiIcons data array

// Draw selected icon using rectangles pixel-by-pixel

// Get icon bit data
// NOTE: Bit data array grouped as unsigned int (ICON_SIZE*ICON_SIZE/32 elements)

// Set icon bit data
// NOTE: Data must be provided as unsigned int array (ICON_SIZE*ICON_SIZE/32 elements)

// Set icon pixel value

// This logic works for any RICON_SIZE pixels icons,
// For example, in case of 16x16 pixels, every 2 lines fit in one unsigned int data element

// Clear icon pixel value

// This logic works for any RICON_SIZE pixels icons,
// For example, in case of 16x16 pixels, every 2 lines fit in one unsigned int data element

// Check icon pixel value

// RAYGUI_SUPPORT_ICONS

//----------------------------------------------------------------------------------
// Module specific Functions Definition
//----------------------------------------------------------------------------------

// Split controls text into multiple strings
// Also check for multiple columns (required by GuiToggleGroup())

// NOTE: Current implementation returns a copy of the provided string with '\0' (string end delimiter)
// inserted between strings defined by "delimiter" parameter. No memory is dynamically allocated,
// all used memory is static... it has some limitations:
//      1. Maximum number of possible split strings is set by TEXTSPLIT_MAX_TEXT_ELEMENTS
//      2. Maximum size of text to split is TEXTSPLIT_MAX_TEXT_LENGTH
// NOTE: Those definitions could be externally provided if required

// Count how many substrings we have on text and point to every one

// Set an end of string at this point

// Convert color data from RGB to HSV
// NOTE: Color data should be passed normalized

// Value

// Undefined, maybe NAN?

// NOTE: If max is 0, this divide would cause a crash
// Saturation

// NOTE: If max is 0, then r = g = b = 0, s = 0, h is undefined

// Undefined, maybe NAN?

// NOTE: Comparing float values could not work properly
// Between yellow & magenta

// Between cyan & yellow
// Between magenta & cyan

// Convert to degrees

// Convert color data from HSV to RGB
// NOTE: Color data should be passed normalized

// NOTE: Comparing float values could not work properly

// Returns a Color struct from hexadecimal value

// Returns hexadecimal value for a Color

// Check if point is inside rectangle

// Color fade-in or fade-out, alpha goes from 0.0f to 1.0f

// Formatting of text with variables to 'embed'

// Draw rectangle filled with color

// Draw rectangle border lines with color

// Draw rectangle with vertical gradient fill color
// NOTE: This function is only used by GuiColorPicker()

// Size of static buffer: TextSplit()
// Size of static pointers array: TextSplit()

// Split string into multiple strings

// NOTE: Current implementation returns a copy of the provided string with '\0' (string end delimiter)
// inserted between strings defined by "delimiter" parameter. No memory is dynamically allocated,
// all used memory is static... it has some limitations:
//      1. Maximum number of possible split strings is set by TEXTSPLIT_MAX_SUBSTRINGS_COUNT
//      2. Maximum size of text to split is TEXTSPLIT_MAX_TEXT_BUFFER_LENGTH

// Count how many substrings we have on text and point to every one

// Set an end of string at this point

// Get integer value from text
// NOTE: This function replaces atoi() [stdlib.h]

// RAYGUI_STANDALONE

// RAYGUI_IMPLEMENTATION
