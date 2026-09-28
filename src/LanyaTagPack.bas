Attribute VB_Name = "LanyaTagPack"
' ============================================================
' 吊牌排版增强包（LanyaTagPack）
' 适用：CorelDRAW X4（VBA6）  32/64 位新版本可用
' 功能：不同规格混拼 / 自动出血 / 角线组（套准十字+裁切角线）
' 说明：与 LYVBA / vbabox 并存，独立 GMS，不修改作者产物。
' 宏列表：
'   TagMixPacking          不同规格混拼（Shelf 矩形打包）
'   TagAddBleed            自动出血（模式1 背景扩展 / 模式2 描边加圈）
'   TagCornerMarks         生成角线组（四角套准十字+裁切角线，四边裁切标记）
'   TagRemoveCornerMarks   删除角线组
' ============================================================

Option Explicit

' ---------- 共用：取角线图层（不存在则创建） ----------
Private Function GetMarksLayer() As Layer
    On Error Resume Next
    Set GetMarksLayer = ActivePage.Layers("LY_TAG_MARKS")
    On Error GoTo 0
    If GetMarksLayer Is Nothing Then
        Set GetMarksLayer = ActivePage.CreateLayer("LY_TAG_MARKS")
    End If
End Function

' ============================================================
' 宏1：不同规格混拼
' ============================================================
Public Sub TagMixPacking()
    On Error GoTo ErrHandler
    Dim ssr As ShapeRange
    Set ssr = ActiveSelectionRange
    If ssr.Count = 0 Then
        MsgBox "请先选中要拼版的吊牌（每个吊牌 = 一个对象或一个组）", vbExclamation, "混拼"
        Exit Sub
    End If

    Dim sheetW As Double, sheetH As Double, gap As Double
    sheetW = Val(InputBox("印刷大版宽度（mm）：", "混拼", "700"))
    sheetH = Val(InputBox("印刷大版高度（mm）：", "混拼", "1000"))
    gap = Val(InputBox("吊牌间距（mm，默认=2×出血）：", "混拼", "6"))
    If sheetW <= 0 Or sheetH <= 0 Then Exit Sub
    If gap < 0 Then gap = 0

    Dim oldUnit As Long
    oldUnit = ActiveDocument.Unit
    ActiveDocument.Unit = cdrMillimeter
    ActiveDocument.ReferencePoint = cdrBottomLeft

    Dim n As Long, i As Long, j As Long, k As Long, t As Long
    n = ssr.Count
    Dim ws() As Double, hs() As Double, idx() As Long
    ReDim ws(1 To n), hs(1 To n), idx(1 To n)
    Dim bx As Double, by As Double, bw As Double, bh As Double
    For i = 1 To n
        ssr(i).GetBoundingBox bx, by, bw, bh
        ws(i) = bw
        hs(i) = bh
        idx(i) = i
    Next i

    ' 按面积降序（冒泡）
    For i = 1 To n - 1
        For j = i + 1 To n
            If ws(idx(j)) * hs(idx(j)) > ws(idx(i)) * hs(idx(i)) Then
                t = idx(i): idx(i) = idx(j): idx(j) = t
            End If
        Next j
    Next i

    ' Shelf 排布
    Dim x As Double, y As Double, rowH As Double
    Dim posX() As Double, posY() As Double
    ReDim posX(1 To n), posY(1 To n)
    x = gap: y = gap: rowH = 0
    Dim fit As Boolean
    fit = True
    For i = 1 To n
        k = idx(i)
        If x + ws(k) > sheetW - gap Then
            x = gap
            y = y + rowH + gap
            rowH = 0
        End If
        If y + hs(k) > sheetH - gap Then
            fit = False
            Exit For
        End If
        posX(k) = x
        posY(k) = y
        If hs(k) > rowH Then rowH = hs(k)
        x = x + ws(k) + gap
    Next i

    If Not fit Then
        ActiveDocument.Unit = oldUnit
        MsgBox "放不下：请减少吊牌数量或增大版面", vbExclamation, "混拼"
        Exit Sub
    End If

    ActiveDocument.BeginCommandGroup
    Application.Optimization = True
    For i = 1 To n
        ssr(i).SetPosition posX(i), posY(i)
    Next i
    Application.Optimization = False
    ActiveDocument.EndCommandGroup
    ActiveWindow.Refresh
    Application.Refresh
    ActiveDocument.Unit = oldUnit

    MsgBox "混拼完成：" & n & " 个吊牌已排入 " & sheetW & "×" & sheetH & "mm 版面（间距 " & gap & "mm）", vbInformation, "混拼"
    Exit Sub

ErrHandler:
    Application.Optimization = False
    ActiveDocument.Unit = oldUnit
    MsgBox "混拼失败：" & Err.Description, vbExclamation, "混拼"
End Sub

' ============================================================
' 宏2：自动出血
' ============================================================
Public Sub TagAddBleed()
    On Error GoTo ErrHandler
    Dim ssr As ShapeRange
    Set ssr = ActiveSelectionRange
    If ssr.Count = 0 Then
        MsgBox "请先选中吊牌对象", vbExclamation, "自动出血"
        Exit Sub
    End If

    Dim mode As Long, bleed As Double
    mode = Val(InputBox("出血模式：1 = 背景图向外扩展   2 = 描边加一圈", "自动出血", "1"))
    If mode <> 1 And mode <> 2 Then Exit Sub
    bleed = Val(InputBox("出血值（mm）：", "自动出血", "3"))
    If bleed <= 0 Then Exit Sub

    Dim oldUnit As Long
    oldUnit = ActiveDocument.Unit
    ActiveDocument.Unit = cdrMillimeter

    ActiveDocument.BeginCommandGroup
    Application.Optimization = True

    Dim s As Shape
    If mode = 1 Then
        ' 模式1：背景矩形中心不动、四边向外扩展
        ActiveDocument.ReferencePoint = cdrCenter
        For Each s In ssr
            s.SetSize s.SizeWidth + 2 * bleed, s.SizeHeight + 2 * bleed
        Next s
    Else
        ' 模式2：生成扩展底色块置于底层（描边加一圈）
        Dim bx As Double, by As Double, bw As Double, bh As Double
        ssr.GetBoundingBox bx, by, bw, bh
        ActiveDocument.ReferencePoint = cdrBottomLeft
        Dim bkg As Shape
        Set bkg = ActiveLayer.CreateRectangle2(bx - bleed, by - bleed, bw + 2 * bleed, bh + 2 * bleed)
        ' 取选中对象中第一个可读均匀填充色的颜色作底色；读不到用白色
        Dim sh As Shape, rr As Long, gg As Long, bb As Long, got As Boolean
        got = False
        For Each sh In ssr
            On Error Resume Next
            Err.Clear
            rr = sh.Fill.UniformColor.RGB.Red
            If Err.Number = 0 Then
                gg = sh.Fill.UniformColor.RGB.Green
                bb = sh.Fill.UniformColor.RGB.Blue
                If Err.Number = 0 Then got = True
            End If
            On Error GoTo ErrHandler
            If got Then Exit For
        Next sh
        If got Then
            bkg.Fill.ApplyUniformFill CreateRGBColor(rr, gg, bb)
        Else
            bkg.Fill.ApplyUniformFill CreateRGBColor(255, 255, 255)
        End If
        bkg.Outline.SetNoOutline
        bkg.OrderToBack
    End If

    Application.Optimization = False
    ActiveDocument.EndCommandGroup
    ActiveWindow.Refresh
    Application.Refresh
    ActiveDocument.Unit = oldUnit

    MsgBox "出血完成：" & bleed & "mm（模式" & mode & "）", vbInformation, "自动出血"
    Exit Sub

ErrHandler:
    Application.Optimization = False
    ActiveDocument.Unit = oldUnit
    MsgBox "自动出血失败：" & Err.Description, vbExclamation, "自动出血"
End Sub

' ============================================================
' 宏3：角线组（套准十字 + 裁切角线，四角四边）
' ============================================================
Public Sub TagCornerMarks()
    On Error GoTo ErrHandler
    Dim ext As Double, markLen As Double, lw As Double
    ext = Val(InputBox("角线外延（mm）：", "角线组", "5"))
    markLen = Val(InputBox("角线线长（mm）：", "角线组", "8"))
    lw = Val(InputBox("线宽（mm）：", "角线组", "0.1"))
    If ext < 0 Or markLen <= 0 Or lw <= 0 Then Exit Sub

    Dim oldUnit As Long
    oldUnit = ActiveDocument.Unit
    ActiveDocument.Unit = cdrMillimeter
    ActiveDocument.ReferencePoint = cdrBottomLeft

    ' 基准边界：选中对象整体边界；无选择用页面
    Dim x1 As Double, y1 As Double, w As Double, h As Double
    If ActiveSelectionRange.Count > 0 Then
        ActiveSelectionRange.GetBoundingBox x1, y1, w, h
    Else
        x1 = 0
        y1 = 0
        w = ActivePage.SizeWidth
        h = ActivePage.SizeHeight
    End If
    Dim x2 As Double, y2 As Double
    x2 = x1 + w
    y2 = y1 + h

    ' 图层
    Dim lyr As Layer
    Set lyr = GetMarksLayer()
    lyr.Activate

    Dim col As Color
    Set col = CreateRegistrationColor

    ActiveDocument.BeginCommandGroup
    Application.Optimization = True

    ' --- 四角裁切角线（L 形） ---
    ' 左下
    DrawMarkLine lyr, x1 - ext, y1, x1 + markLen, y1, lw, col
    DrawMarkLine lyr, x1, y1 - ext, x1, y1 + markLen, lw, col
    ' 右下
    DrawMarkLine lyr, x2 - markLen, y1, x2 + ext, y1, lw, col
    DrawMarkLine lyr, x2, y1 - ext, x2, y1 + markLen, lw, col
    ' 左上
    DrawMarkLine lyr, x1 - ext, y2, x1 + markLen, y2, lw, col
    DrawMarkLine lyr, x1, y2 - markLen, x1, y2 + ext, lw, col
    ' 右上
    DrawMarkLine lyr, x2 - markLen, y2, x2 + ext, y2, lw, col
    DrawMarkLine lyr, x2, y2 - markLen, x2, y2 + ext, lw, col

    ' --- 四角套准十字（角点外侧对角方向） ---
    Dim crHalf As Double, off As Double
    crHalf = markLen / 2
    off = ext + crHalf
    DrawCross lyr, x1 - off, y1 - off, crHalf, lw, col
    DrawCross lyr, x2 + off, y1 - off, crHalf, lw, col
    DrawCross lyr, x1 - off, y2 + off, crHalf, lw, col
    DrawCross lyr, x2 + off, y2 + off, crHalf, lw, col

    ' --- 四边中点裁切标记（朝外） ---
    Dim cx As Double, cy As Double
    cx = x1 + w / 2
    cy = y1 + h / 2
    DrawMarkLine lyr, cx, y2, cx, y2 + ext + markLen, lw, col
    DrawMarkLine lyr, cx, y1, cx, y1 - ext - markLen, lw, col
    DrawMarkLine lyr, x1, cy, x1 - ext - markLen, cy, lw, col
    DrawMarkLine lyr, x2, cy, x2 + ext + markLen, cy, lw, col

    Application.Optimization = False
    ActiveDocument.EndCommandGroup
    ActiveWindow.Refresh
    Application.Refresh
    ActiveDocument.Unit = oldUnit

    MsgBox "角线组已生成（图层 LY_TAG_MARKS：四角套准十字+裁切角线，四边裁切标记）", vbInformation, "角线组"
    Exit Sub

ErrHandler:
    Application.Optimization = False
    ActiveDocument.Unit = oldUnit
    MsgBox "角线组失败：" & Err.Description, vbExclamation, "角线组"
End Sub

' ============================================================
' 宏4：删除角线组
' ============================================================
Public Sub TagRemoveCornerMarks()
    On Error GoTo ErrHandler
    Dim lyr As Layer
    Set lyr = ActivePage.Layers("LY_TAG_MARKS")
    lyr.Shapes.All.Delete
    ActiveWindow.Refresh
    Application.Refresh
    MsgBox "角线组已删除", vbInformation, "角线组"
    Exit Sub
ErrHandler:
    MsgBox "未找到角线组图层 LY_TAG_MARKS（可能已删除）", vbExclamation, "角线组"
End Sub

' ---------- 辅助：画一条标记线 ----------
Private Sub DrawMarkLine(lyr As Layer, x1 As Double, y1 As Double, x2 As Double, y2 As Double, lw As Double, col As Color)
    Dim ln As Shape
    Set ln = lyr.CreateLineSegment(x1, y1, x2, y2)
    ln.Outline.SetProperties lw, Color:=col
End Sub

' ---------- 辅助：画十字 ----------
Private Sub DrawCross(lyr As Layer, cx As Double, cy As Double, half As Double, lw As Double, col As Color)
    DrawMarkLine lyr, cx - half, cy, cx + half, cy, lw, col
    DrawMarkLine lyr, cx, cy - half, cx, cy + half, lw, col
End Sub
