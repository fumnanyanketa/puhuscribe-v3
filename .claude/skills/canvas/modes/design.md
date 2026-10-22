# /canvas design

Define the whole look before any screen is built in code. Deciding the look
while building means rebuilding every screen twice.

## The work

### Step A: Research the look (with the user)

1. Send the user to gather references: Pinterest and Dribbble searches for
   "[app type] mobile UI" (15 plus 10 saves), Mobbin for complete real app
   flows, screenshots of apps they already love.
2. Help them pick ONE visual direction and compress it into one sentence,
   for example: "clean and calm, lots of white space, rounded corners, one
   deep green accent." That sentence is the north star for everything.
3. Fair play boundary: references inspire your own version. Cloning a
   design pixel for pixel and shipping it is not acceptable.

### Step B: Generate assets, in this exact order

1. The signature brand element FIRST: logo, mascot, or hero illustration.
   Its style becomes the reference for everything else.
2. Every other illustration in that same style, always attaching the brand
   element as the reference image. Prompt shape:
   "Create a [style sentence] illustration for [screen]. Reference
   attached. Match the reference exactly on color palette, line weight,
   character proportions, and lighting. Transparent background."
3. The unglamorous states people forget: empty state, success state,
   error state, for every major screen.
4. Save everything into design/assets/ with descriptive names
   (mascot-happy.png, empty-lessons.png). Export at the resolutions the
   platform needs.

### Step C: Hand the direction to /develop

1. Generate the main screens as pictures. Refine with the user until they
   love them. Real assets in place, so spacing comes out right.
2. Write design/brief.md: the one sentence direction, the reference links
   or screenshots that shaped it, the brand element and its style notes,
   the asset list with file names, and the screen pictures. This is the
   reference /develop reads when it creates design.md and the CSS tokens.
   Do not write color codes, type scales, or spacing values here; /develop
   derives those and checks contrast before writing any CSS.
3. From this moment the brand element is the style reference for every
   future asset. New illustrations always attach it as the reference image.

## Done looks like

One sentence direction, a full assets folder including empty, success, and
error states, and design/brief.md ready for /develop.
