<?xml version="1.0" encoding="UTF-8" ?>
<!--

		MINDMAPEXPORTFILTER tex Latex custom

		(c) 2016 by Fredrik Teschke
		licensed under GPLv3
		based on prior work by Naoki Nose and Eric Lavarde on mm2wordml_utf8.xsl

		supported attributes on root node
			head-maxlevel (int): any node greater than this depth is itemized rather than creating a new structure level (e.g. chapter, section, ...)
			droptext (boolean): itemized text is not output
			image_directory (string): relative or absolute path from latex document to docear image directory (symlink advised, e.g. `mklink /D docear_images "..\...\_data\...\default_files\"`)

		supported attributes on nodes
			NoHeading: if attribute is present, the node and all childern are itemized
			LastHeading: if attribute is present, all children are itemized
			label: set custom \label (if wanting to use a \ref within the text, as ooposed to the auto-generated ref when using arrow links in docear)
			cite_info: if present, it is passed to \cite as [optional parameter] (e.g. use it to set the page: 'p. 19')
			image: if attribute is present, the figure located at $image_directory/$image is inserted
			image_width: used for width of figure if present
			drop: do not output node and children
			code: output node as \begin{lstlisting}...\end{lstlisting}
			latex: output node without formatting
			image_row: images of child nodes are arranged in a row (image_width is mandatory for child nodes)
			image_sideways: rotate image 90 degrees
         alternatively apply a style applied with the same name to the node
	-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:func="http://exslt.org/functions">
	<xsl:output encoding="UTF-8" omit-xml-declaration="yes"/>
	<xsl:variable name="newline">
		<xsl:text>
</xsl:text>
	</xsl:variable>

	<!--
		the variable to be used to determine the maximum level of headings, it
		is defined by the attribute 'head-maxlevel' of the root node if it
		exists, else it's the default 4 (maximum possible is 6)
	-->
	<xsl:variable name="maxlevel">
		<xsl:choose>
			<xsl:when test="//map/node/attribute[@NAME='head-maxlevel']">
				<xsl:value-of select="//map/node/attribute[@NAME='head-maxlevel']/@VALUE"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'4'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!--
		the variable to be used to determine whether text nodes should be displayed
	-->
	<xsl:variable name="droptext">
		<xsl:choose>
			<xsl:when test="//map/node/attribute[@NAME='droptext']">
				<xsl:value-of select="//map/node/attribute[@NAME='droptext']/@VALUE"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'false'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!--
		the variable to be used to find images from the directory of the latex file (relative or absolute)
	-->
	<xsl:variable name="image_directory">
		<xsl:choose>
			<xsl:when test="//map/node/attribute[@NAME='image_directory']">
				<xsl:value-of select="//map/node/attribute[@NAME='image_directory']/@VALUE"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'/'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- start at root -->
	<xsl:template match="map">
		<xsl:apply-templates mode="heading"/>
	</xsl:template>

	<!-- output each node as heading -->
	<xsl:template match="node" mode="heading">
		<xsl:param name="level" select="0"/>
		<xsl:choose>
			<xsl:when test="@STYLE_REF = 'drop' or attribute[@NAME = 'drop']">
				<!-- ignore node -->
			</xsl:when>
			<!-- we change our mind if the NoHeading attribute is present, in this case we this node and its children -->
			<xsl:when test="attribute/@NAME = 'NoHeading' or @STYLE_REF = 'NoHeading'">
				<xsl:call-template name="itemize">
					<xsl:with-param name="i" select="." />
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
								<xsl:value-of select="concat($newline, '\chapter{')"/>
							</xsl:when>
							<xsl:when test="$level = 2">
								<xsl:value-of select="concat($newline, '\section{')"/>
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
						<xsl:call-template name="output-node"/>
						<xsl:value-of select="concat('}', $newline)"/>
					</xsl:otherwise>
				</xsl:choose>
				<!--
					if the level is higher than maxlevel, or if the current node is
					marked with LastHeading, we start outputting normal paragraphs,
					else we loop back into the heading mode
				-->
				<xsl:choose>
					<xsl:when test="attribute/@NAME = 'LastHeading' or @STYLE_REF = 'LastHeading'">
						<xsl:call-template name="itemize"/>
					</xsl:when>
					<xsl:when test="$level &lt; $maxlevel">
						<xsl:apply-templates mode="heading" select="node">
							<xsl:with-param name="level" select="$level + 1"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="itemize"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- output nodes as itemized list -->
	<xsl:template name="itemize">
		<xsl:param name="i" select="./node"/>
		<xsl:if test="$droptext = 'false' and $i">
			<xsl:value-of select="concat('\begin{itemize}', $newline)"/>
			<xsl:for-each select="$i">
				<xsl:choose>
					<xsl:when test="@STYLE_REF = 'drop' or attribute[@NAME = 'drop']">
						<!-- do nothing -->
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>\item </xsl:text>
						<xsl:call-template name="output-node"/>
						<xsl:value-of select="$newline"/>
						<!-- no recursive call for image_row children -->
						<xsl:if test="not(attribute/@NAME = 'image_row')">
							<!-- recursive call -->
							<xsl:call-template name="itemize"/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			<xsl:value-of select="concat('\end{itemize}', $newline)"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="output-node">
		<!-- if node is an image -->
		<xsl:choose>
			<xsl:when test="attribute/@NAME = 'image'">
				<xsl:call-template name="output-node-as-image"/>
			</xsl:when>
			<xsl:when test="attribute/@NAME = 'image_row'">
				<xsl:call-template name="output-node-as-image-row"/>
			</xsl:when>
			<xsl:when test="@STYLE_REF = 'latex' or attribute/@NAME = 'latex'">
				<xsl:call-template name="output-node-as-latex"/>
			</xsl:when>
			<xsl:when test="@STYLE_REF = 'code' or attribute/@NAME = 'code'">
				<xsl:call-template name="output-node-as-code"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="output-node-as-text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="output-node-as-text">
		<xsl:call-template name="output-node-text-as-text"/>
		<xsl:call-template name="output-node-text-as-bodytext">
			<xsl:with-param name="contentType" select="'DETAILS'"/>
		</xsl:call-template>
		<xsl:call-template name="output-node-text-as-bodytext">
			<xsl:with-param name="contentType" select="'NOTE'"/>
		</xsl:call-template>

		<!-- use both @ID of node, and user-defined attribute 'label' as latex \label -->
		<xsl:if test="@ID != ''">
			<xsl:value-of select="concat('\label{', @ID, '}')"/>
		</xsl:if>
		<xsl:if test="attribute/@NAME = 'label'">
			<xsl:value-of select="concat('\label{', attribute[@NAME='label']/@VALUE, '}')"/>
		</xsl:if>

		<!-- translate arrow to ref -->
		<xsl:if test="arrowlink/@DESTINATION != ''">
			<xsl:text>, see \autoref{</xsl:text>
			<!-- can have several pointers -->
			<xsl:for-each select="arrowlink/@DESTINATION">
		    	<xsl:value-of select="concat(., '')"/>
			</xsl:for-each>
		  	<xsl:text>}</xsl:text>
		</xsl:if>
		<!-- output citation, one node can only have one -->
		<xsl:if test="attribute[@NAME = 'key']">
      	  	<xsl:value-of select="concat(' \cite[', attribute[@NAME = 'cite_info']/@VALUE, ']{', attribute[@NAME = 'key']/@VALUE, '}')" />
		</xsl:if>
	</xsl:template>

	<xsl:template name="output-node-text-as-text">
		<xsl:choose>
			<xsl:when test="@TEXT">
				<xsl:value-of disable-output-escaping="yes" select="normalize-space(@TEXT)"/>
			</xsl:when>
			<xsl:when test="richcontent[@TYPE='NODE']">
				<xsl:value-of disable-output-escaping="yes" select="normalize-space(richcontent[@TYPE='NODE']/html/body)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="output-node-text-as-bodytext">
		<xsl:param name="contentType"/>
		<xsl:if test="richcontent[@TYPE=$contentType]">
			<xsl:value-of disable-output-escaping="yes" select="string(richcontent[@TYPE='DETAILS']/html/body)"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="output-node-as-image">
		<xsl:variable name="image_width">
			<xsl:choose>
				<xsl:when test="attribute[@NAME='image_width']">
					<xsl:value-of select="attribute[@NAME='image_width']/@VALUE"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'\textwidth'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="figure">
			<xsl:choose>
				<xsl:when test="attribute/@NAME = 'image_sideways'">
					<xsl:text>sidewaysfigure</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>figure</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="position">
			<xsl:choose>
				<!-- sidewaysimage does not work with [H] parameter -->
				<xsl:when test="attribute/@NAME = 'image_sideways'">
					<xsl:text></xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>[H]</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:value-of select="concat('\begin{', $figure, '}', $position)" />
		<xsl:text>
\begin{center}
\includegraphics[width=</xsl:text>
		<xsl:value-of select="concat($image_width, ']{')" />
		<xsl:value-of disable-output-escaping="yes" select="concat($image_directory, '/', attribute[@NAME='image']/@VALUE)"/>
		<xsl:text>}
\caption{</xsl:text>
		<xsl:call-template name="output-node-as-text"/>
		<xsl:text>}
\end{center}
</xsl:text>
		<xsl:value-of select="concat('\end{', $figure, '}', $newline)" />
	</xsl:template>

	<xsl:template name="output-node-as-subimage">
		<xsl:text>
	\begin{subfigure}[b]{</xsl:text>
		<xsl:value-of select="attribute[@NAME='image_width']/@VALUE"/>
		<xsl:text>}
		\includegraphics[width=\textwidth]{</xsl:text>
		<xsl:value-of disable-output-escaping="yes" select="concat($image_directory, '/', attribute[@NAME='image']/@VALUE)"/>
		<xsl:text>}
		\caption{</xsl:text>
		<xsl:call-template name="output-node-as-text"/>
		<xsl:text>}
	\end{subfigure}</xsl:text>
	</xsl:template>

	<xsl:template name="output-node-as-image-row">
		<xsl:param name="i" select="./node"/>
		<xsl:variable name="figure">
			<xsl:choose>
				<xsl:when test="attribute/@NAME = 'image_sideways'">
					<xsl:text>sidewaysfigure</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>figure</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="position">
			<xsl:choose>
				<!-- sidewaysimage does not work with [H] parameter -->
				<xsl:when test="attribute/@NAME = 'image_sideways'">
					<xsl:text></xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>[H]</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:value-of select="concat('\begin{', $figure, '}', $position)" />
		<xsl:text>
	\begin{center}</xsl:text>

		<xsl:for-each select="$i">
			<xsl:call-template name="output-node-as-subimage"/>
		</xsl:for-each>

		<xsl:text>
	\caption{</xsl:text>
		<xsl:call-template name="output-node-as-text"/>
		<xsl:text>}
	\end{center}
</xsl:text>
		<xsl:value-of select="concat('\end{', $figure, '}', $newline)" />
	</xsl:template>

	<xsl:template name="output-node-as-code">
		<xsl:text>\begin{lstlisting}</xsl:text>
		<xsl:value-of disable-output-escaping="yes" select="@TEXT"/>
		<xsl:text>\end{lstlisting}</xsl:text>
	</xsl:template>

	<xsl:template name="output-node-as-latex">
		<xsl:value-of disable-output-escaping="yes" select="@TEXT"/>
	</xsl:template>
</xsl:stylesheet>
