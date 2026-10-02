package com.emzaro.liquidglasslauncher

import android.app.Activity
import android.os.Bundle
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.view.View
import android.widget.*
import androidx.core.view.WindowCompat

class MainActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)
        setContentView(home())
    }

    private fun glass(bg: Int = 0x55FFFFFF, radius: Float = 42f): GradientDrawable =
        GradientDrawable().apply { setColor(bg); cornerRadius = radius; setStroke(1, 0x66FFFFFF) }

    private fun home(): View {
        val root = FrameLayout(this).apply { setBackgroundColor(Color.rgb(18,20,28)) }
        val search = TextView(this).apply {
            text = "⌕  Search apps"; textSize = 17f; setTextColor(Color.WHITE)
            gravity = Gravity.CENTER_VERTICAL; setPadding(28,0,20,0); background = glass(0x35FFFFFF)
        }
        root.addView(search, FrameLayout.LayoutParams(-1,64).apply { setMargins(24,70,24,0) })

        val dock = LinearLayout(this).apply { orientation = LinearLayout.HORIZONTAL; gravity = Gravity.CENTER; background = glass(0x45FFFFFF, 36f); setPadding(14,10,14,10) }
        listOf("☎","✉","🌐","⚙").forEach { s -> dock.addView(TextView(this).apply { text=s; textSize=28f; gravity=17; setTextColor(Color.WHITE) }, LinearLayout.LayoutParams(0,64,1f)) }
        root.addView(dock, FrameLayout.LayoutParams(-1,84,Gravity.BOTTOM).apply { setMargins(24,0,24,28) })

        search.setOnClickListener { showApps(root) }
        return root
    }

    private fun showApps(root: FrameLayout) {
        root.removeAllViews()
        val list = LinearLayout(this).apply { orientation=LinearLayout.VERTICAL; setPadding(24,70,24,24) }
        val title = TextView(this).apply { text="Apps"; textSize=30f; setTextColor(Color.WHITE); setPadding(0,0,0,24) }
        list.addView(title)
        val apps = packageManager.getInstalledApplications(0).filter { it.flags and ApplicationInfo.FLAG_SYSTEM == 0 }.sortedBy { it.loadLabel(packageManager).toString() }
        apps.take(60).forEach { app ->
            val row=TextView(this).apply { text=app.loadLabel(packageManager); textSize=18f; setTextColor(Color.WHITE); gravity=16; background=glass(0x28FFFFFF,24f); setPadding(22,0,22,0) }
            row.setOnClickListener { startActivity(packageManager.getLaunchIntentForPackage(app.packageName)) }
            list.addView(row, LinearLayout.LayoutParams(-1,62).apply { setMargins(0,0,0,10) })
        }
        val scroll=ScrollView(this); scroll.addView(list); root.addView(scroll)
    }
}
