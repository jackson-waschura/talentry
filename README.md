# talentry
Personal projects as talent trees.

Talentry allows you to track your skills and projects as RPG talent trees. It gamifies personal development, encouraging you to take on new challenges and expand your skills.

## Overview

Talentry visualizes your progress as levels achieved in a collection of talent trees. Starting from the root of each talent tree, you can track the levels of skills you've unlocked.

## Scenes

### Main Menu

The main menu is the first scene that appears when the game starts. It allows you to navigate to the project selection menu or settings menu. It also allows you to exit.

### Settings Menu

The settings menu allows you to configure global settings.

### Project Selector

The project selector shows a list of all the projects you've created. You can select a project to open it or create a new project.

### Project Menu

The project menu shows a list of all the talent trees in the project. You can view stats about each tree and select a tree to view it.

### Project Options

This scene allows you to rename a project, delete it, or change the project's path. It also allows you to navigate to the settings menu.

### Tree Viewer

The tree viewer allows you to scroll through the talent tree, view unlocked skills, set goals, and update progress.

### Skill Editor

The skill editor allows you to create new skills and edit existing ones.

## Project Structure

A `Project` is a collection of `Trees` and some metadata.

```
Project
{
    name: string (name of the project)
    trees: list[string] (filenames of the trees in the project)
}
```

A `Tree` is a collection of `Nodes` and some metadata.

```
Tree
{
    name: string;
    nodes: list[Node];
}
```
A `Node` is a skill that can be unlocked.
```
Node
{
    name: string;
    description: string;
    level: int;
    max_level: int;
    children: list[string] (names of the children nodes)
    parents: list[string] (names of the parent nodes)
}
```

## To Do

- [X] Project selector v0
  - [X] Define project save file format
  - [X] Create project flow (open dialogue, provide name)
  - [X] Populate grid with project thumbnails based on found projects
  - [X] Select project flow (set global state, change scene to project menu)
- [X] Project menu v0
  - [X] Define tree save file format
  - [X] Create tree flow (open dialogue, provide name)
  - [X] Populate tree view with tree data
  - [X] Select tree flow (change scene to tree viewer)
- [ ] Tree viewer v0
  - [X] Create Tree viewer GUI to display tree name and back button
  - [X] Read tree data and construct nodes
  - [X] Connect nodes with lines/curves
  - [X] Calculate graph layout left to right
  - [X] Enable scrolling
  - [ ] Add custom tooltips to skill nodes
- [ ] Edit Tree flow
  - [ ] Create a new skill node
  - [ ] Change connections
  - [ ] Change tree name
  - [ ] Change tree levels and icons
  - [ ] Change tree description
- [ ] Minor Polish
  - [ ] Change project thumbnails to be custom
  - [ ] Change UI colors to be more cohesive
  - [ ] Add settings to change UI colors
  - [ ] Add settings to change UI font size
  - [ ] Add attribution / appreciation to free assets used (font, UI, etc)
    - Font: https://managore.itch.io/m5x7
    - UI: https://kenney-assets.itch.io/fantasy-ui-borders
  - [X] Add a "Talentry" logo
  - [ ] Add a Talentry + "Made with Godot" splash screen
  - [ ] Enable skipping splash screen by performing any action
- [ ] Code Cleanup
  - [ ] Generalize the thumbnail scene to be used for both project and tree thumbnails