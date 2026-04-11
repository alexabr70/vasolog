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
            views.setTextViewText(R.id.widget_weekly, "За неделю: $weekly")

            // Склонение слова "день"
            val label = when {
                streak % 10 == 1 && streak % 100 != 11 -> "день без приступа"
                streak % 10 in 2..4 && (streak % 100 < 10 || streak % 100 >= 20) -> "дня без приступа"
                else -> "дней без приступа"
            }
            views.setTextViewText(R.id.widget_label, label)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
