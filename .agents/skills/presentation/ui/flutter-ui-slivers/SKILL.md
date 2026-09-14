---
name: flutter-ui-slivers
description: Slivers-first scrolling architecture skill. Enforces CustomScrollView composition, collapsible SliverAppBars (pinned/floating/stretch), SliverList.builder, SliverGrid, custom SliverPersistentHeaders with persistent tabs, and lazy viewport building. Use when creating complex scrollable views, dashboards, or parallax headers.
---

# Flutter Slivers-First Scrolling Architecture Guide

## 1. Overview & When to Apply

Use this skill whenever:
- Designing complex scrollable screens containing headers, pinned tabs, carousels, lists, and grids.
- Eliminating layout overflow errors (`Vertical viewport was given unbounded height`).
- Implementing collapsible, floating, or stretching app bars (`SliverAppBar.large`, `SliverAppBar` with `pinned: true`).
- Pinning tab bars or search inputs to the top of the screen on scroll (`SliverPersistentHeader`).
- Optimizing scrolling frame rates via lazy sliver loading (`SliverList.builder`, `SliverGrid.builder`).

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [flutter-ui-hub](../flutter-ui-hub/SKILL.md) | Presentation laws and UI routing. |
| **UI Performance** | [flutter-ui-performance](../flutter-ui-performance/SKILL.md) | RepaintBoundary and raster optimization. |
| **Performance Lists & Slivers** | [performance-lists-slivers](../../performance/performance-lists-slivers/SKILL.md) | Extent optimization, prototypeItem, findChildIndexCallback, and keepAlive. |
| **Material 3** | [flutter-ui-material](../flutter-ui-material/SKILL.md) | Theme styling for app bars and list items. |

---

## 3. Why Slivers-First Over Nested Lists

Nested `ListView`s inside `SingleChildScrollView` or `Column` suffer from two major flaws:
1. **Unbounded Height Crash:** `ListView` attempts to take infinite height unless given rigid bounds.
2. **Loss of Lazy Evaluation:** `shrinkWrap: true` instantiates every single list item at once, destroying memory efficiency and frame rates.

**The Solution:** A unified **`CustomScrollView`** where all components coordinate their scroll offsets within a single viewport.

---

## 4. Standard Slivers-First Implementation Pattern

```dart
class FeatureDashboardPage extends StatelessWidget {
  const FeatureDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // 1. Collapsible Large App Bar
          const SliverAppBar.large(
            title: Text('Dashboard'),
            pinned: true,
            floating: false,
          ),

          // 2. Non-Sliver Widget Adapter (Header/Banner)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: DashboardBannerCard(),
            ),
          ),

          // 3. Section Title
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),

          // 4. Lazy-Loaded Sliver List with Padding
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList.builder(
              itemCount: 50,
              itemBuilder: (context, index) {
                return TransactionListTile(index: index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 5. Pinned TabBar with `SliverPersistentHeader`

To pin a tab bar or filter bar to the top of the screen during scrolling:

```dart
class PinnedTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const PinnedTabBarDelegate({required this.tabBar});

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: context.colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant PinnedTabBarDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar;
  }
}

// In your CustomScrollView slivers list:
SliverPersistentHeader(
  pinned: true,
  delegate: PinnedTabBarDelegate(
    tabBar: const TabBar(
      tabs: [Tab(text: 'All'), Tab(text: 'Pending'), Tab(text: 'Completed')],
    ),
  ),
);
```

---

## 6. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| `SingleChildScrollView` + `Column` wrapping large `ListView` | **CRITICAL** | Convert to `CustomScrollView` with `SliverList.builder`. |
| Using `shrinkWrap: true` on long lists to fix layout errors | **HIGH** | Use `CustomScrollView` or wrap list in `Expanded` if inside a `Column`. |
| Putting heavy widget logic inside non-lazy `SliverList.list` | **HIGH** | Use `SliverList.builder` with `itemCount` for lazy element allocation. |
| Hardcoding fixed heights for sliver headers without delegate bounds | **MEDIUM** | Implement `SliverPersistentHeaderDelegate` with exact `minExtent` and `maxExtent`. |

---

## 7. Verification Checklist

- [ ] All complex multi-component scrolling views use `CustomScrollView`.
- [ ] Large lists inside sliver views use `SliverList.builder` (not `SliverList.list`).
- [ ] Persistent headers implement `SliverPersistentHeaderDelegate` with valid bounds.
- [ ] Pull-to-refresh (`RefreshIndicator`) wraps `CustomScrollView` cleanly.
- [ ] No `shrinkWrap: true` workarounds exist in scrollable paths.
