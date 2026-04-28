package com.vasolog.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class VasoLogWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.vasolog_widget)

            val streak = widgetData.getInt("streak", 0)
            val weekly = widgetData.getInt("weekly", 0)

            views.setTextViewText(R.id.widget_streak, "$streak")
            // Строки из ресурсов - корректно локализуются на всех языках
            views.setTextViewText(R.id.widget_label, context.getString(R.string.widget_days_label))
            views.setTextViewText(
                R.id.widget_weekly,
                "${context.getString(R.string.widget_weekly_prefix)} $weekly"
            )

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
