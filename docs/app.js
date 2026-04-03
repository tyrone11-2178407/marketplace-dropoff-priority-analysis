const formatters = {
  integer: new Intl.NumberFormat("en-US", { maximumFractionDigits: 0 }),
  decimal: new Intl.NumberFormat("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
  currency: new Intl.NumberFormat("en-US", { style: "currency", currency: "USD", maximumFractionDigits: 2 }),
};

const config = {
  colors: {
    accent: "#2f5bff",
    accentSoft: "rgba(47, 91, 255, 0.18)",
    warn: "#e46e37",
    warnSoft: "rgba(228, 110, 55, 0.18)",
    good: "#3f8554",
    goodSoft: "rgba(63, 133, 84, 0.16)",
    text: "#181a1f",
    grid: "rgba(24, 26, 31, 0.08)",
  },
};

function categoryTickCallback(axis) {
  return function categoryLabel(value) {
    return this.getLabelForValue(value);
  };
}

function currencyTick(value) {
  return `$${formatters.integer.format(value)}`;
}

function percentTick(value) {
  return `${formatters.decimal.format(value)}%`;
}

function defaultTooltipTitle(items) {
  return items[0]?.label ?? "";
}

const chartDefaults = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      labels: {
        usePointStyle: true,
        boxWidth: 8,
        color: config.colors.text,
        font: { family: "Inter, Segoe UI, sans-serif", size: 12 },
      },
    },
    tooltip: {
      backgroundColor: "rgba(24, 26, 31, 0.92)",
      titleColor: "#fff",
      bodyColor: "#fff",
      padding: 12,
      cornerRadius: 12,
      callbacks: {
        title: defaultTooltipTitle,
      },
    },
  },
  scales: {
    x: {
      grid: { color: config.colors.grid },
      ticks: { color: "#5d6272" },
      border: { display: false },
    },
    y: {
      grid: { display: false },
      ticks: { color: "#5d6272" },
      border: { display: false },
    },
  },
};

function formatValue(value, type) {
  const numeric = Number(value);
  if (type === "currency") return formatters.currency.format(numeric);
  if (type === "percent") return `${formatters.decimal.format(numeric)}%`;
  if (type === "integer") return formatters.integer.format(numeric);
  return formatters.decimal.format(numeric);
}

function createHeadlineStats(data) {
  const stats = [
    {
      label: "Completion rate",
      value: formatValue(data.kpis.completion_rate_pct, "percent"),
      note: "High top-line order completion.",
    },
    {
      label: "Late delivery rate",
      value: formatValue(data.kpis.late_delivery_rate_pct, "percent"),
      note: "Frequent enough to matter materially.",
    },
    {
      label: "Delayed order value",
      value: formatValue(data.kpis.delayed_order_value, "currency"),
      note: "Much larger than canceled order value.",
    },
  ];

  document.getElementById("hero-stats").innerHTML = stats
    .map(
      (stat) => `
        <article class="headline-stat">
          <p class="headline-stat__label">${stat.label}</p>
          <p class="headline-stat__value">${stat.value}</p>
          <p class="headline-stat__note">${stat.note}</p>
        </article>
      `
    )
    .join("");
}

function createMetricCards(data) {
  const cards = [
    ["Total orders", formatValue(data.kpis.total_orders, "integer"), "Validated from the SQLite order table."],
    ["Completion rate", formatValue(data.kpis.completion_rate_pct, "percent"), "Delivered orders divided by total orders."],
    ["Cancellation rate", formatValue(data.kpis.cancellation_rate_pct, "percent"), "Small in volume, but not zero in value."],
    ["Late delivery rate", formatValue(data.kpis.late_delivery_rate_pct, "percent"), "The main friction signal in the project."],
    ["Avg review score", formatValue(data.kpis.avg_review_score, "decimal"), "Marketplace-wide customer sentiment."],
    ["Low review rate", formatValue(data.kpis.low_review_rate_pct, "percent"), "Reviews with score 1 or 2."],
    ["Canceled value", formatValue(data.kpis.canceled_order_value, "currency"), "Direct value leakage from cancellations."],
    ["Delayed value", formatValue(data.kpis.delayed_order_value, "currency"), "Orders delivered late, still putting value at risk."],
  ];

  document.getElementById("health-kpis").innerHTML = cards
    .map(
      ([label, value, note]) => `
        <article class="metric-card">
          <p class="metric-card__label">${label}</p>
          <p class="metric-card__value">${value}</p>
          <p class="metric-card__note">${note}</p>
        </article>
      `
    )
    .join("");
}

function renderPriorityCards(data) {
  const top = data.priority.slice(0, 3);
  document.getElementById("priority-cards").innerHTML = top
    .map(
      (item, index) => `
        <article class="priority-card">
          <div class="priority-card__rank">${index + 1}</div>
          <h3>${item.issue}</h3>
          <p>${item.recommended_action}</p>
          <div class="priority-meta">
            <span class="chip">Score ${item.priority_score}</span>
            <span class="chip">${item.owner}</span>
            <span class="chip">${item.metric_to_monitor}</span>
          </div>
        </article>
      `
    )
    .join("");

  document.getElementById("priority-table-body").innerHTML = data.priority
    .map(
      (item) => `
        <tr>
          <td>${item.issue}</td>
          <td>${item.priority_score}</td>
          <td>${item.owner}</td>
          <td><code>${item.metric_to_monitor}</code></td>
          <td>${item.recommended_action}</td>
        </tr>
      `
    )
    .join("");
}

function makeBarChart(id, labels, dataValues, label, colors, options = {}) {
  const ctx = document.getElementById(id);
  const indexAxis = options.indexAxis || "x";
  const xIsCategory = indexAxis === "y";
  const yIsCategory = indexAxis === "x";

  return new Chart(ctx, {
    type: options.type || "bar",
    data: {
      labels,
      datasets: [
        {
          label,
          data: dataValues,
          backgroundColor: colors.background,
          borderColor: colors.border,
          borderWidth: 1.5,
          borderRadius: 10,
          borderSkipped: false,
        },
      ],
    },
    options: {
      ...chartDefaults,
      indexAxis,
      layout: {
        padding: options.layoutPadding || { left: 8, right: 8, top: 4, bottom: 0 },
      },
      plugins: {
        ...chartDefaults.plugins,
        legend: { display: options.showLegend ?? false },
        tooltip: {
          ...chartDefaults.plugins.tooltip,
          callbacks: {
            title: options.tooltipTitle || defaultTooltipTitle,
            label: options.tooltipLabel,
          },
        },
      },
      scales: {
        x: {
          ...chartDefaults.scales.x,
          ticks: {
            color: "#5d6272",
            callback: xIsCategory ? categoryTickCallback("x") : options.xTickCallback,
          },
        },
        y: {
          ...chartDefaults.scales.y,
          ticks: {
            color: "#5d6272",
            callback: yIsCategory ? categoryTickCallback("y") : options.yTickCallback,
          },
        },
      },
    },
  });
}

function renderCharts(data) {
  makeBarChart(
    "statusChart",
    data.orderStatus.map((d) => d.order_status_label),
    data.orderStatus.map((d) => d.orders),
    "Orders",
    { background: "rgba(47, 91, 255, 0.16)", border: "#2f5bff" },
    {
      indexAxis: "y",
      xTickCallback: (value) => formatters.integer.format(value),
      tooltipLabel: (context) => ` ${formatters.integer.format(context.parsed.x)} orders`,
      layoutPadding: { left: 20, right: 12, top: 4, bottom: 0 },
    }
  );

  makeBarChart(
    "funnelChart",
    data.funnel.map((d) => d.funnel_stage_label),
    data.funnel.map((d) => d.orders),
    "Orders",
    { background: "rgba(47, 91, 255, 0.14)", border: "#2f5bff" },
    {
      showLegend: false,
      xTickCallback: (value) => formatters.integer.format(value),
      tooltipLabel: (context) => ` ${formatters.integer.format(context.parsed.y)} orders`,
    }
  );

  makeBarChart(
    "revenueLeakageChart",
    data.revenueLeakage.map((d) => d.issue_label),
    data.revenueLeakage.map((d) => d.value_at_risk),
    "Value at risk",
    { background: "rgba(228, 110, 55, 0.18)", border: "#e46e37" },
    {
      yTickCallback: currencyTick,
      tooltipLabel: (context) => ` ${formatters.currency.format(context.parsed.y)}`,
    }
  );

  makeBarChart(
    "cancelCategoryChart",
    data.canceledByCategory.slice(0, 6).map((d) => d.product_category_label),
    data.canceledByCategory.slice(0, 6).map((d) => d.canceled_order_value),
    "Canceled order value",
    { background: "rgba(228, 110, 55, 0.16)", border: "#e46e37" },
    {
      indexAxis: "y",
      xTickCallback: currencyTick,
      tooltipTitle: (items) => data.canceledByCategory[items[0].dataIndex].product_category_full_label,
      tooltipLabel: (context) => ` ${formatters.currency.format(context.parsed.x)}`,
      layoutPadding: { left: 32, right: 12, top: 4, bottom: 0 },
    }
  );

  makeBarChart(
    "reviewDistributionChart",
    data.reviewDistribution.map((d) => d.review_score_label),
    data.reviewDistribution.map((d) => d.share_of_reviews_pct),
    "Share of reviews",
    { background: "rgba(47, 91, 255, 0.16)", border: "#2f5bff" },
    {
      yTickCallback: percentTick,
      tooltipLabel: (context) => ` ${formatters.decimal.format(context.parsed.y)}% of reviews`,
    }
  );

  makeBarChart(
    "reviewDelayChart",
    data.reviewByDelay.map((d) => d.delay_bucket_label),
    data.reviewByDelay.map((d) => d.avg_review_score),
    "Average review score",
    { background: "rgba(228, 110, 55, 0.16)", border: "#e46e37" },
    {
      yTickCallback: (value) => formatters.decimal.format(value),
      tooltipLabel: (context) => ` Avg review score ${formatters.decimal.format(context.parsed.y)}`,
    }
  );
}

function renderOpsChart(data) {
  const ctx = document.getElementById("opsChart");
  const opsViews = {
    seller: {
      labels: data.lateDeliveryBySeller.slice(0, 6).map((d) => d.seller_label),
      values: data.lateDeliveryBySeller.slice(0, 6).map((d) => d.late_delivery_rate_pct),
      label: "Late delivery rate %",
      xTickCallback: percentTick,
      tooltipTitle: (items) => data.lateDeliveryBySeller[items[0].dataIndex].seller_full_label,
      tooltipLabel: (context) => ` ${formatters.decimal.format(context.parsed.x)}% late delivery rate`,
    },
    category: {
      labels: data.lateDeliveryByCategory.slice(0, 6).map((d) => d.product_category_label),
      values: data.lateDeliveryByCategory.slice(0, 6).map((d) => d.late_delivery_rate_pct),
      label: "Late delivery rate %",
      xTickCallback: percentTick,
      tooltipTitle: (items) => data.lateDeliveryByCategory[items[0].dataIndex].product_category_full_label,
      tooltipLabel: (context) => ` ${formatters.decimal.format(context.parsed.x)}% late delivery rate`,
    },
    state: {
      labels: data.canceledByState.map((d) => d.seller_state_label),
      values: data.canceledByState.map((d) => d.canceled_order_value),
      label: "Canceled order value",
      xTickCallback: currencyTick,
      tooltipLabel: (context) => ` ${formatters.currency.format(context.parsed.x)}`,
    },
  };

  const chart = new Chart(ctx, {
    type: "bar",
    data: {
      labels: opsViews.seller.labels,
      datasets: [
        {
          label: opsViews.seller.label,
          data: opsViews.seller.values,
          backgroundColor: "rgba(228, 110, 55, 0.16)",
          borderColor: "#e46e37",
          borderWidth: 1.5,
          borderRadius: 10,
          borderSkipped: false,
        },
      ],
    },
    options: {
      ...chartDefaults,
      indexAxis: "y",
      plugins: {
        ...chartDefaults.plugins,
        legend: { display: false },
      },
      scales: {
        x: {
          ...chartDefaults.scales.x,
          ticks: {
            color: "#5d6272",
            callback: opsViews.seller.xTickCallback,
          },
        },
        y: {
          ...chartDefaults.scales.y,
          ticks: {
            color: "#5d6272",
            callback: categoryTickCallback("y"),
          },
        },
      },
    },
  });

  document.querySelectorAll("[data-ops-view]").forEach((button) => {
    button.addEventListener("click", () => {
      const key = button.dataset.opsView;
      const view = opsViews[key];
      chart.data.labels = view.labels;
      chart.data.datasets[0].data = view.values;
      chart.data.datasets[0].label = view.label;
      chart.options.scales.x.ticks.callback = view.xTickCallback;
      chart.options.plugins.tooltip.callbacks.title = view.tooltipTitle || defaultTooltipTitle;
      chart.options.plugins.tooltip.callbacks.label = view.tooltipLabel;
      chart.update();

      document.querySelectorAll("[data-ops-view]").forEach((btn) => btn.classList.remove("is-active"));
      button.classList.add("is-active");
    });
  });
}

function setupRevealAndNav() {
  const sections = document.querySelectorAll(".reveal");
  const navLinks = [...document.querySelectorAll(".rail__nav a")];

  const revealObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) entry.target.classList.add("is-visible");
      });
    },
    { threshold: 0.12 }
  );

  sections.forEach((section) => revealObserver.observe(section));

  const navObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        navLinks.forEach((link) => link.classList.toggle("is-active", link.getAttribute("href") === `#${entry.target.id}`));
      });
    },
    { rootMargin: "-35% 0px -55% 0px", threshold: 0 }
  );

  document.querySelectorAll("main .section").forEach((section) => navObserver.observe(section));
}

async function main() {
  const response = await fetch("./data/site-data.json");
  const data = await response.json();
  createHeadlineStats(data);
  createMetricCards(data);
  renderPriorityCards(data);
  renderCharts(data);
  renderOpsChart(data);
  setupRevealAndNav();
}

main().catch((error) => {
  console.error("Failed to load site data", error);
});
