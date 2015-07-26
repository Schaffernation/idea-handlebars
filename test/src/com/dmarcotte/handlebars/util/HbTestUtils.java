package com.dmarcotte.handlebars.util;

import com.dmarcotte.handlebars.config.HbConfig;
import com.intellij.openapi.Disposable;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.util.Disposer;
import org.jetbrains.annotations.NotNull;

import java.io.File;

public class HbTestUtils {
    /**
     * The root of the test data directory
     */
    public static final String BASE_TEST_DATA_PATH = new File("test", "data").getAbsolutePath();

    public static void setOpenHtmlAsHandlebars(final boolean value, @NotNull final Project project, @NotNull Disposable parentDisposable) {
        final boolean oldValue = HbConfig.shouldOpenHtmlAsHandlebars(project);
        if (oldValue == value) return;

        HbConfig.setShouldOpenHtmlAsHandlebars(value, project);
        Disposer.register(parentDisposable, new Disposable() {
            @Override
            public void dispose() {
                HbConfig.setShouldOpenHtmlAsHandlebars(oldValue, project);
            }
        });
    }
}
