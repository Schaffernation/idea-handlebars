package icons;

import com.intellij.openapi.util.IconLoader;

import javax.swing.*;

/**
 * Upsteam in https://github.com/JetBrains/intellij-plugins/handlebars, this file is generated, but for backports
 * here we maintain it by hand.
 */
public class HandlebarsIcons {
  private static Icon load(String path) {
    return IconLoader.getIcon(path, HandlebarsIcons.class);
  }

  
  public static class Elements {
    public static final Icon OpenBlock = load("/icons/elements/openBlock.png"); // 16x16
    public static final Icon OpenInverse = load("/icons/elements/openInverse.png"); // 16x16
    public static final Icon OpenMustache = load("/icons/elements/openMustache.png"); // 16x16
    public static final Icon OpenPartial = load("/icons/elements/openPartial.png"); // 16x16
    public static final Icon OpenUnescaped = load("/icons/elements/openUnescaped.png"); // 16x16

  }
  public static final Icon Handlebars_icon = load("/icons/handlebars_icon.png"); // 16x16
}
