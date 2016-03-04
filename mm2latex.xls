<?xml version="1.0" encoding="UTF-8" ?>
<!--

		MINDMAPEXPORTFILTER tex Latex custom
	-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes" encoding="UTF-8" />

  <xsl:variable name='newline'><xsl:text>
</xsl:text></xsl:variable>

  <!--
		the variable to be used to determine the maximum level of headings, it
		is defined by the attribute 'head-maxlevel' of the root node if it
		exists, else it's the default 4 (maximum possible is 6)
	-->
  <xsl:variable name="maxlevel">
    <xsl:choose>
      <xsl:when test="//map/node/attribute[@NAME='head-maxlevel']">
        <xsl:value-of select="//map/node/attribute[@NAME='head-maxlevel']/@VALUE" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'4'" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template match="map">
    <xsl:apply-templates mode="heading"/>
  </xsl:template>

  <!-- output each node as heading -->
  <xsl:template match="node" mode="heading">
    <xsl:param name="level" select="0" />
    <xsl:choose>
      <!-- we change our mind if the NoHeading attribute is present, in this case we itemize single item -->
      <xsl:when test="attribute/@NAME = 'NoHeading'">
        <xsl:call-template name="itemize">
          <xsl:with-param name="i" select="."/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$level = 0">
            <!-- Do nothing with root node -->
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$level = 1">
                <xsl:value-of select="concat($newline, '\chapter{')" />
              </xsl:when>
              <xsl:when test="$level = 2">
                <xsl:value-of select="concat($newline, '\section{')" />
              </xsl:when>
              <xsl:when test="$level = 3">
                <xsl:text>\subsection{</xsl:text>
              </xsl:when>
              <xsl:when test="$level = 4">
                <xsl:text>\subsubsection{</xsl:text>
              </xsl:when>
              <xsl:when test="$level = 5">
                <xsl:text>\paragraph{</xsl:text>
              </xsl:when>
              <xsl:when test="$level = 6">
                <xsl:text>\subparagraph{</xsl:text>
              </xsl:when>
            </xsl:choose>
            <xsl:call-template name="output-node" />
            <xsl:value-of select="concat('}', $newline)" />
          </xsl:otherwise>
        </xsl:choose>
        <!--
					if the level is higher than maxlevel, or if the current node is
					marked with LastHeading, we start outputting normal paragraphs,
					else we loop back into the heading mode
				-->
        <xsl:choose>
          <xsl:when test="attribute/@NAME = 'LastHeading'">
            <xsl:call-template name="itemize" />
          </xsl:when>
          <xsl:when test="$level &lt; $maxlevel">
            <xsl:apply-templates select="node" mode="heading">
              <xsl:with-param name="level" select="$level + 1" />
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="itemize" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- output nodes as itemized list -->
  <xsl:template name="itemize">
    <xsl:param name="i" select="./node" />
    <xsl:value-of select="concat('\begin{itemize}', $newline)" />
    <xsl:for-each select="$i">
      <xsl:text>\item </xsl:text>
      <xsl:call-template name="output-node" />
      <xsl:value-of select="$newline" />

      <!-- recursive call if children present -->
      <xsl:if test="./node">
        <xsl:call-template name="itemize" />
      </xsl:if>
    </xsl:for-each>
    <xsl:value-of select="concat('\end{itemize}', $newline)" />
  </xsl:template>

  <xsl:template name="output-node">
    <xsl:call-template name="output-node-text-as-text" />
    <xsl:call-template name="output-note-text-as-bodytext">
      <xsl:with-param name="contentType" select="'DETAILS'"/>
    </xsl:call-template>
    <xsl:call-template name="output-note-text-as-bodytext">
      <xsl:with-param name="contentType" select="'NOTE'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="output-node-text-as-text">
    <xsl:choose>
      <xsl:when test="attribute[@NAME = 'key']">
        <xsl:text>\cite{</xsl:text>
        <xsl:value-of select="attribute[@NAME = 'key']/@VALUE" />
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:when test="@TEXT">
        <xsl:value-of select="normalize-space(@TEXT)" />
      </xsl:when>
      <xsl:when test="richcontent[@TYPE='NODE']">
        <xsl:value-of select="normalize-space(richcontent[@TYPE='NODE']/html/body)" disable-output-escaping="yes" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:text></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="output-note-text-as-bodytext">
    <xsl:param name="contentType"></xsl:param>
    <xsl:if test="richcontent[@TYPE=$contentType]">
      <xsl:value-of select="string(richcontent[@TYPE='DETAILS']/html/body)" disable-output-escaping="yes" />
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
