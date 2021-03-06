context("test-ggstrat-plot_addons.R")

test_that("facet reordering works", {

  p <- mtcars %>%
    dplyr::mutate(
      # factor not in sorted order
      cyl_fct = paste("cyl =", cyl) %>% factor(levels = c("cyl = 8", "cyl = 4", "cyl = 6")),
      # character
      gear_fct = paste("gear =", gear)
    ) %>%
    ggplot2::ggplot(ggplot2::aes(wt, mpg)) +
    ggplot2::geom_point() +

    # additional layer with character versions of what is a factor in original data
    ggplot2::geom_point(
      ggplot2::aes(x = 5, y = mpg_line),
      data = tibble::tibble(
        gear_fct = c("gear = 3", "gear = 4", "gear = 5", "gear = 6"),
        cyl_fct = c("cyl = 4", "cyl = 6", "cyl = 8", "cyl = 2"),
        mpg_line = c(15, 25, 35, 45)
      ),
      col = "red"
    )

  print(
    p +
      ggplot2::facet_grid(ggplot2::vars(cyl_fct), ggplot2::vars(gear_fct)) +
      sequential_layer_facets() +
      ggplot2::labs(caption = "cyl order: 8 4 6 2")
  )

  print(
    p +
      ggplot2::facet_wrap(ggplot2::vars(cyl_fct, gear_fct)) +
      sequential_layer_facets() +
      ggplot2::labs(caption = "cyl order: 8 4 6 2")
  )

  expect_silent(
    print(
      p + ggplot2::facet_null()
    )
  )

  expect_true(TRUE)
})

test_that("CONISS can be added to a plot", {

  coniss <- alta_lake_geochem %>%
    nested_data(age, param, value, trans = scale) %>%
    nested_chclust_coniss()

  print(
    ggplot2::ggplot(alta_lake_geochem, ggplot2::aes(x = value, y = age)) +
      geom_lineh() +
      facet_geochem_gridh(vars(param)) +
      layer_dendrogram(coniss, ggplot2::aes(y = age), param = "CONISS") +
      layer_zone_boundaries(coniss, ggplot2::aes(y = age)) +
      ggplot2::labs(caption = "CONISS at the right plus boundary lines in the right place")
  )

  print(
    ggplot2::ggplot(alta_lake_geochem, ggplot2::aes(x = age, y = value)) +
      ggplot2::geom_line() +
      facet_geochem_grid(vars(param)) +
      layer_dendrogram(coniss, ggplot2::aes(x = age), param = "CONISS") +
      layer_zone_boundaries(coniss, ggplot2::aes(x = age)) +
      ggplot2::labs(caption = "CONISS at the bottom plus boundary lines in the right place")
  )

  grp_coniss <- keji_lakes_plottable %>%
    dplyr::group_by(location) %>%
    nested_data(depth, taxon, rel_abund) %>%
    nested_chclust_coniss()

  print(
    patchwork::wrap_plots(
      ggplot2::ggplot(keji_lakes_plottable, ggplot2::aes(x = rel_abund, y = depth)) +
        geom_col_segsh() +
        ggplot2::scale_y_reverse() +
        facet_abundanceh(vars(taxon), vars(location)),

      plot_layer_dendrogram(grp_coniss, ggplot2::aes(y = depth), taxon = "CONISS") +
        ggplot2::facet_grid(rows = vars(location), cols = vars(taxon)) +
        ggplot2::scale_y_reverse(),

      nrow = 1
    )
  )

  print(
    patchwork::wrap_plots(
      ggplot2::ggplot(keji_lakes_plottable, ggplot2::aes(x = depth, y = rel_abund)) +
        geom_col_segs() +
        facet_abundance(vars(taxon), vars(location)),

      plot_layer_dendrogram(grp_coniss, ggplot2::aes(x = depth), taxon = "CONISS") +
        ggplot2::facet_grid(cols = vars(location)) +
        ggplot2::scale_y_reverse() +
        ggplot2::labs(caption = "scale_y_reverse should be correct with dendrogram"),

      ncol = 1
    )
  )

  expect_true(TRUE)
})

test_that("PCAs can be added to a plot", {

  pca <- alta_lake_geochem %>%
    nested_data(age, param, value, trans = scale) %>%
    nested_prcomp()

  print(
    ggplot2::ggplot(alta_lake_geochem, ggplot2::aes(x = value, y = age)) +
      geom_lineh() +
      facet_geochem_gridh(vars(param)) +
      layer_scores(pca, key = "param", which = c("PC1", "PC2")) +
      ggplot2::labs(caption = "PCA scores at the right")
  )

  print(
    ggplot2::ggplot(alta_lake_geochem, ggplot2::aes(y = value, x = age)) +
      ggplot2::geom_line() +
      facet_geochem_grid(vars(param)) +
      layer_scores(pca, key = "param", value = "value", which = c("PC1", "PC2")) +
      ggplot2::labs(caption = "PCA scores at the bottom")
  )

  grp_pca <- keji_lakes_plottable %>%
    dplyr::group_by(location) %>%
    nested_data(depth, taxon, rel_abund, trans = sqrt) %>%
    nested_prcomp()

  print(
    patchwork::wrap_plots(
      ggplot2::ggplot(keji_lakes_plottable, ggplot2::aes(x = rel_abund, y = depth)) +
        geom_col_segsh() +
        ggplot2::scale_y_reverse() +
        facet_abundanceh(vars(taxon), vars(location)),

      plot_layer_scores(grp_pca, ggplot2::aes(y = depth), which = c("PC1", "PC2")) +
        ggplot2::scale_y_reverse(),

      nrow = 1
    )
  )

  print(
    patchwork::wrap_plots(
      ggplot2::ggplot(keji_lakes_plottable, ggplot2::aes(y = rel_abund, x = depth)) +
        geom_col_segs() +
        facet_abundance(vars(taxon), vars(location)),

      plot_layer_scores(grp_pca, ggplot2::aes(x = depth), which = c("PC1", "PC2")),

      ncol = 1
    )
  )

  expect_true(TRUE)
})
