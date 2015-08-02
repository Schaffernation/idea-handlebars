package com.dmarcotte.handlebars.highlighting;

import com.dmarcotte.handlebars.util.HbTestUtils;
import com.intellij.codeInspection.htmlInspections.HtmlUnknownTagInspection;
import com.intellij.testFramework.PlatformTestCase;
import com.intellij.testFramework.fixtures.LightPlatformCodeInsightFixtureTestCase;
import org.jetbrains.annotations.NotNull;

public class HbHighlightingTest extends LightPlatformCodeInsightFixtureTestCase {
  @Override
  protected String getBasePath() {
    return "/highlighting";
  }

  @SuppressWarnings("JUnitTestCaseWithNonTrivialConstructors")
  public HbHighlightingTest() {
    PlatformTestCase.initPlatformLangPrefix();
  }

  @Override
  protected void setUp() throws Exception {
    super.setUp();
    enableInspections();
  }

  @NotNull
  @Override
  protected String getTestDataPath() {
    return HbTestUtils.BASE_TEST_DATA_PATH + getBasePath();
  }

  @Override
  protected boolean isWriteActionRequired() {
    return false;
  }

  private void doTest(String extension) {
    myFixture.configureByFile(getTestName(true) + "." + extension);
    myFixture.checkHighlighting(true, false, true);
  }

  public void testScriptTag() {
    doTest("html");
  }

  public void testUncompletedTag() {
    doTest("hbs");
  }

  public void testUncompletedTagInHandlebars() {
    doTest("hbs");
  }

  private void enableInspections() {
    myFixture.enableInspections(HtmlUnknownTagInspection.class);
  }
}
