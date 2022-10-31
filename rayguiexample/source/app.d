module controls_test_suite;
@nogc nothrow:
extern(C): __gshared:
/*******************************************************************************************
*
*   raygui - controls test suite
*
*   TEST CONTROLS:
*       - GuiDropdownBox()
*       - GuiCheckBox()
*       - GuiSpinner()
*       - GuiValueBox()
*       - GuiTextBox()
*       - GuiButton()
*       - GuiComboBox()
*       - GuiListView()
*       - GuiToggleGroup()
*       - GuiTextBoxMulti()
*       - GuiColorPicker()
*       - GuiSlider()
*       - GuiSliderBar()
*       - GuiProgressBar()
*       - GuiColorBarAlpha()
*       - GuiScrollPanel()
*
*
*   DEPENDENCIES:
*       raylib 4.0 - Windowing/input management and drawing.
*       raygui 3.2 - Immediate-mode GUI controls.
*
*   COMPILATION (Windows - MinGW):
*       gcc -o $(NAME_PART).exe $(FILE_NAME) -I../../src -lraylib -lopengl32 -lgdi32 -std=c99
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2016-2022 Ramon Santamaria (@raysan5)
*
**********************************************************************************************/

import raylib;

version = RAYGUI_IMPLEMENTATION;
//#define RAYGUI_CUSTOM_ICONS     // It requires providing gui_icons.h in the same directory
//#include "gui_icons.h"          // External icons data provided, it can be generated with rGuiIcons tool
import raygui;

public import core.stdc.string;             // Required for: strcpy()

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
int main() {
    // Initialization
    //---------------------------------------------------------------------------------------
    const(int) screenWidth = 690;
    const(int) screenHeight = 560;

    InitWindow(screenWidth, screenHeight, "raygui - controls test suite");
    SetExitKey(0);

    // GUI controls initialization
    //----------------------------------------------------------------------------------
    int dropdownBox000Active = 0;
    bool dropDown000EditMode = false;

    int dropdownBox001Active = 0;
    bool dropDown001EditMode = false;

    int spinner001Value = 0;
    bool spinnerEditMode = false;

    int valueBox002Value = 0;
    bool valueBoxEditMode = false;

    char[64] textBoxText = "Text box";
    bool textBoxEditMode = false;

    int listViewScrollIndex = 0;
    int listViewActive = -1;

    int listViewExScrollIndex = 0;
    int listViewExActive = 2;
    int listViewExFocus = -1;
    const(char)*[8] listViewExList = [ "This", "is", "a", "list view", "with", "disable", "elements", "amazing!" ];

    char[256] multiTextBoxText = "Multi text box";
    bool multiTextBoxEditMode = false;
    Color colorPickerValue = Colors.RED;

    int sliderValue = 50;
    int sliderBarValue = 60;
    float progressValue = 0.4f;

    bool forceSquaredChecked = false;

    float alphaValue = 0.5f;

    int comboBoxActive = 1;

    int toggleGroupActive = 0;

    Vector2 viewScroll = { 0, 0 };
    //----------------------------------------------------------------------------------

    // Custom GUI font loading
    //Font font = LoadFontEx("fonts/rainyhearts16.ttf", 12, 0, 0);
    //GuiSetFont(font);

    bool exitWindow = false;
    bool showMessageBox = false;

    char[256] textInput = 0;
    bool showTextInputBox = false;

    char[256] textInputFileName = 0;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!exitWindow)    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        exitWindow = WindowShouldClose();

        if (IsKeyPressed(KeyboardKey.KEY_ESCAPE)) showMessageBox = !showMessageBox;

        if (IsKeyDown(KeyboardKey.KEY_LEFT_CONTROL) && IsKeyPressed(KeyboardKey.KEY_S)) showTextInputBox = true;

        if (IsFileDropped())
        {
            FilePathList droppedFiles = LoadDroppedFiles();

            if ((droppedFiles.count > 0) && IsFileExtension(droppedFiles.paths[0], ".rgs")) GuiLoadStyle(droppedFiles.paths[0]);

            UnloadDroppedFiles(droppedFiles);    // Clear internal buffers
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(GetColor(GuiGetStyle(GuiControl.DEFAULT, GuiDefaultProperty.BACKGROUND_COLOR)));

            // raygui: controls drawing
            //----------------------------------------------------------------------------------
            if (dropDown000EditMode || dropDown001EditMode) GuiLock();
            else if (!dropDown000EditMode && !dropDown001EditMode) GuiUnlock();
            //GuiDisable();

            // First GUI column
            //GuiSetStyle(CHECKBOX, TEXT_ALIGNMENT, TEXT_ALIGN_LEFT);
            forceSquaredChecked = GuiCheckBox(Rectangle( 25, 108, 15, 15 ), "FORCE CHECK!", forceSquaredChecked);

            GuiSetStyle(TEXTBOX, TEXT_ALIGNMENT, TEXT_ALIGN_CENTER);
            //GuiSetStyle(VALUEBOX, TEXT_ALIGNMENT, TEXT_ALIGN_LEFT);
            if (GuiSpinner(Rectangle( 25, 135, 125, 30 ), null, &spinner001Value, 0, 100, spinnerEditMode)) spinnerEditMode = !spinnerEditMode;
            if (GuiValueBox(Rectangle( 25, 175, 125, 30 ), null, &valueBox002Value, 0, 100, valueBoxEditMode)) valueBoxEditMode = !valueBoxEditMode;
            GuiSetStyle(TEXTBOX, TEXT_ALIGNMENT, TEXT_ALIGN_LEFT);
            if (GuiTextBox(Rectangle( 25, 215, 125, 30 ), textBoxText.ptr, 64, textBoxEditMode)) textBoxEditMode = !textBoxEditMode;

            GuiSetStyle(BUTTON, TEXT_ALIGNMENT, TEXT_ALIGN_CENTER);

            if (GuiButton(Rectangle( 25, 255, 125, 30 ), GuiIconText(ICON_FILE_SAVE, "Save File"))) showTextInputBox = true;

            GuiGroupBox(Rectangle( 25, 310, 125, 150 ), "STATES");
            //GuiLock();
            GuiSetState(STATE_NORMAL); if (GuiButton(Rectangle( 30, 320, 115, 30 ), "NORMAL")) { }
            GuiSetState(STATE_FOCUSED); if (GuiButton(Rectangle( 30, 355, 115, 30 ), "FOCUSED")) { }
            GuiSetState(STATE_PRESSED); if (GuiButton(Rectangle( 30, 390, 115, 30 ), "#15#PRESSED")) { }
            GuiSetState(STATE_DISABLED); if (GuiButton(Rectangle( 30, 425, 115, 30 ), "DISABLED")) { }
            GuiSetState(STATE_NORMAL);
            //GuiUnlock();

            comboBoxActive = GuiComboBox(Rectangle( 25, 470, 125, 30 ), "ONE;TWO;THREE;FOUR", comboBoxActive);

            // NOTE: GuiDropdownBox must draw after any other control that can be covered on unfolding
            GuiSetStyle(DROPDOWNBOX, TEXT_ALIGNMENT, TEXT_ALIGN_LEFT);
            if (GuiDropdownBox(Rectangle( 25, 65, 125, 30 ), "#01#ONE;#02#TWO;#03#THREE;#04#FOUR", &dropdownBox001Active, dropDown001EditMode)) dropDown001EditMode = !dropDown001EditMode;

            GuiSetStyle(DROPDOWNBOX, TEXT_ALIGNMENT, TEXT_ALIGN_CENTER);
            if (GuiDropdownBox(Rectangle( 25, 25, 125, 30 ), "ONE;TWO;THREE", &dropdownBox000Active, dropDown000EditMode)) dropDown000EditMode = !dropDown000EditMode;

            // Second GUI column
            listViewActive = GuiListView(Rectangle( 165, 25, 140, 140 ), "Charmander;Bulbasaur;#18#Squirtel;Pikachu;Eevee;Pidgey", &listViewScrollIndex, listViewActive);
            listViewExActive = GuiListViewEx(Rectangle( 165, 180, 140, 200 ), listViewExList.ptr, 8, &listViewExFocus, &listViewExScrollIndex, listViewExActive);

            toggleGroupActive = GuiToggleGroup(Rectangle( 165, 400, 140, 25 ), "#1#ONE\n#3#TWO\n#8#THREE\n#23#", toggleGroupActive);

            // Third GUI column
            if (GuiTextBoxMulti(Rectangle( 320, 25, 225, 140 ), multiTextBoxText.ptr, 256, multiTextBoxEditMode)) multiTextBoxEditMode = !multiTextBoxEditMode;
            colorPickerValue = GuiColorPicker(Rectangle( 320, 185, 196, 192 ), null, colorPickerValue);

            sliderValue = cast(int)GuiSlider(Rectangle( 355, 400, 165, 20 ), "TEST", TextFormat("%2.2f", cast(float)sliderValue), sliderValue, -50, 100);
            sliderBarValue = cast(int)GuiSliderBar(Rectangle( 320, 430, 200, 20 ), null, TextFormat("%i", cast(int)sliderBarValue), sliderBarValue, 0, 100);
            progressValue = GuiProgressBar(Rectangle( 320, 460, 200, 20 ), null, null, progressValue, 0, 1);

            // NOTE: View rectangle could be used to perform some scissor test
            Rectangle view = GuiScrollPanel(Rectangle( 560, 25, 100, 160 ), null, Rectangle( 560, 25, 200, 400 ), &viewScroll);

            GuiPanel(Rectangle( 560, 25 + 180, 100, 160 ), "Panel Info");

            GuiGrid(Rectangle( 560, 25 + 180 + 180, 100, 120 ), null, 20, 2);

            GuiStatusBar(Rectangle( 0, cast(float)GetScreenHeight() - 20, cast(float)GetScreenWidth(), 20 ), "This is a status bar");

            alphaValue = GuiColorBarAlpha(Rectangle( 320, 490, 200, 30 ), null, alphaValue);

            if (showMessageBox)
            {
                DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), Fade(Colors.RAYWHITE, 0.8f));
                int result = GuiMessageBox(Rectangle( cast(float)GetScreenWidth()/2 - 125, cast(float)GetScreenHeight()/2 - 50, 250, 100 ), GuiIconText(ICON_EXIT, "Close Window"), "Do you really want to exit?", "Yes;No");

                if ((result == 0) || (result == 2)) showMessageBox = false;
                else if (result == 1) exitWindow = true;
            }

            if (showTextInputBox)
            {
                DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), Fade(Colors.RAYWHITE, 0.8f));
                int result = GuiTextInputBox(Rectangle( cast(float)GetScreenWidth()/2 - 120, cast(float)GetScreenHeight()/2 - 60, 240, 140 ), "Save", GuiIconText(ICON_FILE_SAVE, "Save file as..."), "Ok;Cancel", textInput.ptr, 255, null);

                if (result == 1)
                {
                    // TODO: Validate textInput value and save

                    strcpy(textInputFileName.ptr, textInput.ptr);
                }

                if ((result == 0) || (result == 1) || (result == 2))
                {
                    showTextInputBox = false;
                    strcpy(textInput.ptr, "\0");
                }
            }
            //----------------------------------------------------------------------------------

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------

    return 0;
}
