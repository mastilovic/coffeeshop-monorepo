---
name: shops_form_redesign
overview: Redesign the Shops creation form so it looks balanced and aligned, keeping the current dark theme while improving layout and spacing, with Address and City arranged more cleanly.
todos: []
isProject: false
---

## Goal

**Improve the Shops creation form layout and spacing** so it feels balanced and aligned, keeps the existing dark theme, and especially fixes the City field being awkwardly far to the right.

## Desired UX

- **Form width**
  - Use a **fixed, relatively narrow max-width** (around 520–600px) and center the form horizontally.
  - Ensure the form remains responsive down to mobile: on small screens it should use nearly full width with standard horizontal padding.

- **Field layout**
  - **Name**: full-width field on its own row.
  - **Address + City**: displayed on the **same row on desktop**, with reasonable column ratios (e.g. Address ~65–70%, City ~30–35%).
  - **Mobile behavior**: below a breakpoint (e.g. 640px or similar, depending on existing design system), stack Address and City vertically (single column) with consistent spacing.
  - **Phone**: full-width field on its own row beneath Address/City.

- **Visual style**
  - Keep the **current dark theme** (background colors, overall mood) but:
    - Tighten **internal padding** inside the card and between fields.
    - Ensure **label-to-input spacing** is consistent (e.g. 4–6px).
    - Ensure **vertical spacing** between form rows is consistent (e.g. 16–20px).
    - Keep inputs with clear, visible borders or subtle outlines that are consistent across all fields (including City).
  - Ensure the **Create** button is left-aligned with the inputs and has sufficient top margin so it is visually anchored to the form fields.

- **Accessibility & feedback**
  - Maintain or improve:
    - Clear label text for each field.
    - Focus states that are visible on dark backgrounds (e.g. lighter border or glow).

## Implementation Plan

- **1. Locate the Shops form component**
  - Identify the React (or appropriate frontend) component that renders this form (for example, something like `[frontend/src/features/shops/ShopForm.tsx](frontend/src/features/shops/ShopForm.tsx)` or `[frontend/src/pages/shops/create.tsx](frontend/src/pages/shops/create.tsx)`).
  - Confirm how the existing layout is created (e.g. CSS grid, flexbox, or a UI library like Tailwind, Chakra, etc.).

- **2. Restructure the layout JSX**
  - Wrap the entire form in a container that enforces max-width and centering, using existing layout utilities or a custom wrapper.
  - Group fields into logical rows:
    - Row 1: Name (single full-width field).
    - Row 2: A container that holds Address and City side by side on desktop.
    - Row 3: Phone (single full-width field).
    - Row 4: Actions row with the Create button.
  - For Address/City row, switch to a **responsive two-column layout**, e.g. using CSS grid or flex with a breakpoint:
    - Desktop: two columns with the desired width ratio.
    - Mobile: columns stack vertically via media query or utility classes.

- **3. Adjust styling (spacing, alignment, borders)**
  - In the component file or its associated stylesheet (e.g. `[frontend/src/features/shops/ShopForm.css](frontend/src/features/shops/ShopForm.css)` or Tailwind utility classes in JSX):
    - Apply consistent vertical spacing between each row.
    - Ensure a consistent `gap` between Address and City columns on desktop.
    - Ensure padding inside the form card provides comfortable breathing room without feeling too spread out.
    - Normalize input heights and border radius so all fields (Name, Address, City, Phone) visually match.
  - Verify the City input alignment: it should line up vertically with Address and not appear shifted or isolated at the far right edge.

- **4. Ensure responsive behavior**
  - Add or update responsive classes/styles so that on small screens:
    - The grid/flex row for Address/City collapses into a single column with both fields full width.
    - Horizontal padding of the card is sufficient to avoid edge-to-edge fields while still utilizing screen width.

- **5. Verify states and interactions**
  - Check hover and focus states on all inputs and the Create button to ensure they are clearly visible on the dark background.
  - Confirm that any inline validation or error messages (if present) still align well within the new layout.

- **6. Manual visual QA**
  - Open the Shops creation page in the browser.
  - Inspect the form at common breakpoints:
    - Large desktop (e.g. ≥ 1280px): form appears as a centered, narrow card; Address/City share a row.
    - Tablet (e.g. ~768px): still looks balanced; columns may still be side-by-side if comfortable.
    - Mobile (≤ 640px): Address and City stack; spacing remains clean.
  - Make any small spacing tweaks needed after visual inspection.

## Todos

- **locate-shops-form**: Find the Shops creation form component and its styles.
- **update-form-layout**: Refactor JSX into rows with a two-column Address/City row on desktop.
- **add-responsive-styles**: Implement responsive behavior so Address and City stack on smaller screens.
- **polish-spacing-and-borders**: Adjust spacing, padding, and input/card borders while keeping the dark theme.
- **visual-qa**: Manually verify the new layout at several screen sizes and tweak if necessary.