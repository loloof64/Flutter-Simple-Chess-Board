## 1.9.0

- Add optional history controls with visual feedback (thank you berkaycatak)
- Fix interaction example (thank you berkaycatak)
- Add history example

## 1.8.0

- Add interactive possible moves visualization and optional last move square highlighting (thank you berkaycatak)
- Add interactive tap-to-move with customizable move indicators (thank you berkaycatak)

## 1.7.1

- Expand readme with an example customizing colors

## 1.7.0

- We can highlight cell with an opacity (we just need to set the opacity to the color).

## 1.6.0

- We can set up illegal position on the board (useful if you don't plan to make it interactive)

## 1.5.0

- We can also highlight cell even if the player in turn is not set to human.

## 1.4.1

- Update README file.

## 1.4.0

- We can choose to highlight some cells, with the parameter `cellHighlights`.
- Added an onTap handler, which is active on every cells.

## 1.3.0

- Now the only way to interact with the board is with Drag and Drop.

## 1.2.0

- No more depending on fpdart, even in pubspecs.lock : this package won't affect your use
  of package fpdart in your project.

## 1.1.0

- Bug fix : the board was not always updated
- Removed the use of package fpdart.

## 1.0.0

- Wrote the chess board from scratch
- You can see an indicator on the chess board when doing a Drag and drop.

## 0.10.0

- The callback onPromotionCommited gives us a ShortMove instance instead of just PieceType.

## 0.9.0

- The callback onPromotionCommited is now effective.

## 0.8.0

- We must add a new callback to the ChessBoard : onPromotionCommited.

## 0.7.0

- We can change colors.

## 0.6.2

- Head of arrow is resized on the basis of the arrow length.

## 0.6.0

- Improved style of arrows.

## 0.5.0

- Reducing thickness of arrows.

## 0.4.2

- Using latest chess package version.

## 0.4.0

- Reducing thickness of arrows.

## 0.3.6

- Improving preview image on documentation.

## 0.3.4

- Preview image is a Png instead of a jpeg.

## 0.3.2

- Updated dependencies.

## 0.3.0

- Updated dependencies and improved formatting.

## 0.2.0

- Previous version did not blocked user from moving pieces on engine turn.

## 0.1.0

- Preventing user from moving pieces when it is not human turn.

## 0.0.3

- Added a note on the board's size computation in the README.

## 0.0.2

- Updated the preview in the README.

## 0.0.1

- Initial release.
