package com.emzaro.liquidglasslauncher

import android.app.Activity
import android.app.Dialog
import android.content.Intent
import android.content.pm.ResolveInfo
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Bundle
import android.view.Gravity
import android.view.Window
import android.view.WindowManager
import android.widget.*
import androidx.core.view.WindowCompat

class MainActivity : Activity() {
    private lateinit var apps: List<ResolveInfo>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)
        enableGlassWindow()
        apps = loadApps()
        setContentView(home())
    }

    private fun dp(v: Int) = (v * resources.displayMetrics.density).toInt()

    private fun enableGlassWindow() {
        window.clearFlags(WindowManager.LayoutParams.FLAG_DIM_BEHIND)
        window.addFlags(WindowManager.LayoutParams.FLAG_BLUR_BEHIND)
        window.setDimAmount(0f)
        window.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        if (Build.VERSION.SDK_INT >= 31) window.setBackgroundBlurRadius(72)
    }

    private fun glass(color: Int = 0x42FFFFFF, radius: Int = 28) =
        GradientDrawable().apply {
            setColor(color)
            cornerRadius = dp(radius).toFloat()
            setStroke(dp(1), 0x66FFFFFF)
        }

    private fun loadApps(): List<ResolveInfo> =
        packageManager.queryIntentActivities(
            Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER), 0
        ).sortedBy { it.loadLabel(packageManager).toString().lowercase() }

    private fun home(): FrameLayout {
        val root = FrameLayout(this).apply {
            setBackgroundColor(0xCC12141C.toInt())
            setPadding(dp(20), dp(56), dp(20), dp(24))
        }
        val column = LinearLayout(this).apply { orientation = LinearLayout.VERTICAL }
        root.addView(column, FrameLayout.LayoutParams(-1, -1))

        val search = TextView(this).apply {
            text = "⌕   Search apps"
            textSize = 17f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER_VERTICAL
            setPadding(dp(22), 0, dp(20), 0)
            background = glass(0x38FFFFFF)
            elevation = dp(8).toFloat()
            setOnClickListener { showApps(root) }
        }
        column.addView(search, LinearLayout.LayoutParams(-1, dp(58)))

        val grid = GridLayout(this).apply {
            columnCount = 4
            setPadding(0, dp(20), 0, dp(8))
        }
        apps.take(8).forEach { grid.addView(appTile(it)) }
        column.addView(grid, LinearLayout.LayoutParams(-1, 0, 1f))

        val folder = TextView(this).apply {
            text = "▦\nFavorites"
            textSize = 13f
            gravity = Gravity.CENTER
            setTextColor(Color.WHITE)
            background = glass(0x30FFFFFF, 24)
            setOnClickListener { showFolder() }
        }
        column.addView(folder, LinearLayout.LayoutParams(-1, dp(72)).apply {
            setMargins(0, 0, 0, dp(12))
        })

        val dock = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
            background = glass(0x48FFFFFF, 36)
            setPadding(dp(8), dp(8), dp(8), dp(8))
            elevation = dp(12).toFloat()
        }
        apps.take(4).forEach { info ->
            dock.addView(ImageButton(this).apply {
                setImageDrawable(info.loadIcon(packageManager))
                background = ColorDrawable(Color.TRANSPARENT)
                contentDescription = info.loadLabel(packageManager)
                setPadding(dp(10), dp(10), dp(10), dp(10))
                setOnClickListener { launch(info) }
            }, LinearLayout.LayoutParams(0, dp(64), 1f))
        }
        column.addView(dock, LinearLayout.LayoutParams(-1, dp(80)))
        return root
    }

    private fun appTile(info: ResolveInfo): LinearLayout {
        val tile = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(dp(5), dp(5), dp(5), dp(5))
            setOnClickListener { launch(info) }
        }
        tile.addView(ImageView(this).apply {
            setImageDrawable(info.loadIcon(packageManager))
            contentDescription = info.loadLabel(packageManager)
        }, LinearLayout.LayoutParams(dp(48), dp(48)))
        tile.addView(TextView(this).apply {
            text = info.loadLabel(packageManager)
            textSize = 11f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            maxLines = 1
        }, LinearLayout.LayoutParams(-1, dp(24)))
        return tile
    }

    private fun showApps(root: FrameLayout) {
        root.removeAllViews()
        val wrapper = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(20), dp(56), dp(20), dp(20))
        }
        val search = EditText(this).apply {
            hint = "Search apps"
            textSize = 18f
            setTextColor(Color.WHITE)
            setHintTextColor(0x99FFFFFF.toInt())
            singleLine = true
            setPadding(dp(22), 0, dp(22), 0)
            background = glass(0x45FFFFFF)
        }
        wrapper.addView(search, LinearLayout.LayoutParams(-1, dp(58)))

        val scroll = ScrollView(this)
        val grid = GridLayout(this).apply {
            columnCount = 4
            setPadding(0, dp(18), 0, dp(20))
        }
        scroll.addView(grid)
        wrapper.addView(scroll, LinearLayout.LayoutParams(-1, 0, 1f))

        val back = TextView(this).apply {
            text = "‹   Home"
            textSize = 16f
            gravity = Gravity.CENTER
            setTextColor(Color.WHITE)
            background = glass(0x38FFFFFF, 24)
            setOnClickListener { setContentView(home()) }
        }
        wrapper.addView(back, LinearLayout.LayoutParams(-1, dp(52)))
        root.addView(wrapper, FrameLayout.LayoutParams(-1, -1))

        fun refresh(q: String) {
            grid.removeAllViews()
            apps.filter { it.loadLabel(packageManager).toString().contains(q, true) }
                .forEach { grid.addView(appTile(it)) }
        }
        refresh("")
        search.addTextChangedListener(object : android.text.TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, st: Int, c: Int, a: Int) = Unit
            override fun onTextChanged(s: CharSequence?, st: Int, b: Int, c: Int) = refresh(s?.toString().orEmpty())
            override fun afterTextChanged(s: android.text.Editable?) = Unit
        })
    }

    private fun showFolder() {
        val dialog = Dialog(this)
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE)
        val panel = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(22), dp(20), dp(22), dp(22))
            background = glass(0xE31A1D25.toInt(), 30)
        }
        panel.addView(TextView(this).apply {
            text = "Favorites"
            textSize = 22f
            setTextColor(Color.WHITE)
            setPadding(0, 0, 0, dp(14))
        })
        val grid = GridLayout(this).apply { columnCount = 4 }
        apps.take(16).forEach { grid.addView(appTile(it)) }
        panel.addView(grid)
        dialog.setContentView(panel)
        dialog.show()
        dialog.window?.apply {
            setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
            addFlags(WindowManager.LayoutParams.FLAG_BLUR_BEHIND)
            setDimAmount(0.12f)
            if (Build.VERSION.SDK_INT >= 31) setBackgroundBlurRadius(42)
            setLayout(dp(340), WindowManager.LayoutParams.WRAP_CONTENT)
        }
    }

    private fun launch(info: ResolveInfo) {
        val intent = packageManager.getLaunchIntentForPackage(info.activityInfo.packageName)
        if (intent != null) startActivity(intent)
    }
}
