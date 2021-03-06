package ${escapeKotlinIdentifiers(packageName)}

import android.annotation.TargetApi
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.preference.ListPreference
import android.preference.Preference
import android.preference.PreferenceActivity
import android.preference.PreferenceFragment
import android.preference.PreferenceManager
import android.preference.RingtonePreference
import android.text.TextUtils
import android.view.MenuItem
<#if parentActivityClass?has_content>
import android.support.v4.app.NavUtils
</#if>

/**
 * A {@link PreferenceActivity} that presents a flat list of application settings 
 * with preference categories.
 */
class ${activityClass} : ${preferenceSuperClass}() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setupActionBar()

        this.fragmentManager.beginTransaction().replace(android.R.id.content, AllPreferenceFragment()).commit()
    }

    /**
     * Set up the [android.app.ActionBar], if the API is available.
     */
    private fun setupActionBar() {
        <#if PreferenceSupport?has_content
             && PreferenceSupport == 'Support'>supportActionBar<#else>actionBar</#if>?.setDisplayHomeAsUpEnabled(true)
    }

<#if parentActivityClass?has_content>
    override fun onMenuItemSelected(featureId: Int, item: MenuItem): Boolean {
        val id = item.itemId
        if (id == android.R.id.home) {
            if (!super.onMenuItemSelected(featureId, item)) {
                NavUtils.navigateUpFromSameTask(this)
            }
            return true
        }
        return super.onMenuItemSelected(featureId, item)
    }
</#if>
    /**
     * {@inheritDoc}
     */
    override fun onIsMultiPane(): Boolean {
        return false
    }

    /**
     * This method stops fragment injection in malicious applications.
     * Make sure to deny any unknown fragments here.
     */
    override fun isValidFragment(fragmentName: String): Boolean {
        return PreferenceFragment::class.java.name == fragmentName
                || AllPreferenceFragment::class.java.name == fragmentName
    }

    /**
     * This fragment shows all preferences
     */
    @TargetApi(Build.VERSION_CODES.HONEYCOMB)
    class AllPreferenceFragment : PreferenceFragment() {
        override fun onCreate(savedInstanceState: Bundle?) {
            super.onCreate(savedInstanceState)
            addPreferencesFromResource(R.xml.pref_all)
            setHasOptionsMenu(true)

            // Bind the summaries of EditText/List/Dialog/Ringtone preferences
            // to their values. When their values change, their summaries are
            // updated to reflect the new value, per the Android Design
            // guidelines.
            bindPreferenceSummaryToValue(findPreference("example_text"))
            bindPreferenceSummaryToValue(findPreference("example_list"))
            bindPreferenceSummaryToValue(findPreference("notifications_new_message_ringtone"))
            bindPreferenceSummaryToValue(findPreference("sync_frequency"))

            // Set static preference summaries
            setPreferenceSummary(findPreference("version"), getVersionName(activity))
        }

        override fun onOptionsItemSelected(item: MenuItem): Boolean {
            val id = item.itemId
            if (id == android.R.id.home) {
                activity.onBackPressed()
                return true
            }
            return super.onOptionsItemSelected(item)
        }
    }

    
    companion object {

        /**
         * A preference value change listener that updates the preference's summary
         * to reflect its new value.
         */
        private val sBindPreferenceSummaryToValueListener = Preference.OnPreferenceChangeListener { preference, value ->
            val stringValue = value.toString()

            if (preference is ListPreference) {
                // For list preferences, look up the correct display value in
                // the preference's 'entries' list.
                val listPreference = preference
                val index = listPreference.findIndexOfValue(stringValue)

                // Set the summary to reflect the new value.
                preference.setSummary(
                        if (index >= 0)
                            listPreference.entries[index]
                        else
                            null)

            } else if (preference is RingtonePreference) {
                // For ringtone preferences, look up the correct display value
                // using RingtoneManager.
                if (TextUtils.isEmpty(stringValue)) {
                    // Empty values correspond to 'silent' (no ringtone).
                    preference.setSummary(R.string.pref_ringtone_silent)

                } else {
                    val ringtone = RingtoneManager.getRingtone(
                            preference.getContext(), Uri.parse(stringValue))

                    if (ringtone == null) {
                        // Clear the summary if there was a lookup error.
                        preference.setSummary(null)
                    } else {
                        // Set the summary to reflect the new ringtone display
                        // name.
                        val name = ringtone.getTitle(preference.getContext())
                        preference.setSummary(name)
                    }
                }

            } else {
                // For all other preferences, set the summary to the value's
                // simple string representation.
                preference.summary = stringValue
            }
            true
        }

        /**
         * Binds a preference's summary to its value. More specifically, when the
         * preference's value is changed, its summary (line of text below the
         * preference title) is updated to reflect the value. The summary is also
         * immediately updated upon calling this method. The exact display format is
         * dependent on the type of preference.

         * @see .sBindPreferenceSummaryToValueListener
         */
        private fun bindPreferenceSummaryToValue(preference: Preference) {
            // Set the listener to watch for value changes.
            preference.onPreferenceChangeListener = sBindPreferenceSummaryToValueListener

            // Trigger the listener immediately with the preference's
            // current value.
            sBindPreferenceSummaryToValueListener.onPreferenceChange(preference,
                    PreferenceManager
                            .getDefaultSharedPreferences(preference.context)
                            .getString(preference.key, ""))
        }

        /**
         * Set a preference's summary to a value.
         */
        private fun setPreferenceSummary(preference: Preference, value: String) {
            preference.summary = value
        }

        /**
         * Get the version name of the current application
         */
        private fun getVersionName(context: Context): String {
            return try {
                context.packageManager.getPackageInfo(context.packageName, 0).versionName
            } catch (e: PackageManager. NameNotFoundException) {
                ""
            }
        }
    }
}
