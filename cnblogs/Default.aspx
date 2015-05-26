﻿<%@ Page Language="C#" AutoEventWireup="true" ValidateRequest="false" CodeBehind="Default.aspx.cs" Inherits="cnblogs.Default" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>博客园博客编辑器</title>
    <link href="Content/assets/css/amazeui.min.css" rel="stylesheet" />
    <script src="Content/assets/js/jquery.min.js"></script>
    <script src="Content/assets/js/jquery.cookie.js"></script>
    <script src="Content/assets/js/amazeui.min.js"></script>
    <script src="Content/ueditor/ueditor.config.js"></script>
    <script src="Content/ueditor/ueditor.all.min.js"></script>
    <script type="text/javascript">
        $(function () {
            var ue = UE.getEditor('Editor', {
                autoHeightEnabled: false
                , elementPathEnabled: false
                , wordCount: false
                , serverUrl: "ueback/controller.ashx"
                , saveInterval: 360000
            });
            var setHeight = function () {
                var h = window.innerHeight - 148;
                if (window.innerWidth < 1480) {
                    h = h - 30;
                }
                ue.setHeight(h);
            }
            ue.ready(function () {
                setHeight();
                ue.execCommand('fontfamily', '微软雅黑');
            });
            window.onresize = setHeight;
            var showLoadingModal = function (title, content) {
                $("#postAlertTitle").html(title);
                $("#postAlertInfo").html(content);
                $("#loadingModal").modal({ closeViaDimmer: 0, width: 280, height: 160 });
            }
            $("#LoginBtn").click(function () {
                var obj = {};
                obj.UserName = $("#UserName").val();
                obj.PassWord = $("#PassWord").val();
                obj.ApiAddress = $("#ApiAddress").val();
                obj.Action = "Login";
                if (obj.ApiAddress.length < 1 || obj.ApiAddress.search("http://rpc.cnblogs.com/metaweblog") == -1) {
                    alert("博客metaweblog API地址有误")
                    return;
                }
                if (obj.UserName.length < 1 || obj.PassWord.length < 1) {
                    alert("用户名或者密码不能为空");
                    return;
                }
                $.post("Default.aspx", obj, function (data) {
                    $.cookie("BlogUserInfo", data, { expires: 365 });
                    $("#blog-modal-login").modal("close");
                });
            })
            $("#SaveBtn").click(function () {
                var obj = {};
                obj.BlogTitle = $("#BlogTitle").val();
                obj.BlogBody = ue.getContent();
                obj.Action = "Save";
                obj.BlogId = $("#BlogId").val();
                if (obj.BlogTitle.length < 1 || obj.BlogBody.length < 10) {
                    alert("博客标题不能为空且博客的内容不能太少");
                    return;
                }
                var cookie = $.cookie('BlogUserInfo');
                if (!cookie) {
                    $("#blog-modal-login").modal({ closeViaDimmer: 1, width: 400, height: 300 });
                    return;
                }
                showLoadingModal("正在发往博客园，请稍后", '<span class="am-icon-spinner am-icon-spin"></span>');
                var tempObj = JSON.parse(cookie);
                obj.CnBlogsUserName = tempObj.CnBlogsUserName;
                obj.CnBlogsPassWord = tempObj.CnBlogsPassWord;
                obj.ApiAddress = tempObj.ApiAddress;
                obj.PicRes = "";
                var pic = $(obj.BlogBody).find("img[src^='/ueback/upload/']");
                for (var i = 0; i < pic.length; i++) {
                    obj.PicRes = obj.PicRes + $(pic[i]).attr("src") + ",";
                }
                $.post("Default.aspx", obj, function (data) {
                    var html = ' <button class="am-btn am-btn-success  am-radius" id="redirectBtn">';
                    html += '<i class="am-icon-rss"></i>';
                    html += '关闭';
                    html += '</button>';
                    $("#postAlertTitle").html(data);
                    $("#postAlertInfo").html(html);
                    $("#redirectBtn").click(function () {
                        $("#loadingModal").modal("close");
                    })
                });
            })
            $("#GetBtn").click(function () {
                var cookie = $.cookie('BlogUserInfo');
                if (!cookie) {
                    $("#blog-modal-login").modal({ closeViaDimmer: 1, width: 400, height: 300 });
                    return;
                }
                showLoadingModal("正在获取最近一篇文章", '<span class="am-icon-spinner am-icon-spin"></span>');
                var tempObj = JSON.parse(cookie);
                var obj = {};
                obj.CnBlogsUserName = tempObj.CnBlogsUserName;
                obj.CnBlogsPassWord = tempObj.CnBlogsPassWord;
                obj.ApiAddress = tempObj.ApiAddress;
                obj.Action = "GetLast";
                $.post("Default.aspx", obj, function (result) {
                    var data = JSON.parse(result);
                    ue.setContent(data.description);
                    $("#BlogTitle").val(data.title);
                    $("#BlogId").val(data.postid);
                    $("#loadingModal").modal("close");
                });
            })
        });
    </script>
    <style>
        html, body {
            height: 100%;
            width: 100%;
            padding: 0px;
            margin: 0px;
            overflow: hidden;
        }

        .rightBtn {
            width: 266px;
            margin-bottom: 12px;
            border: solid 1px #FFFFFF;
        }
    </style>
</head>
<body>

    <div style="height: 100%; margin-top: 12px; margin-left: 12px; margin-right: 300px;">
        <div>
            <form id="form2" class="am-form">
                <input id="BlogTitle" type="text" placeholder="博客标题">
                <input id="BlogId" type="hidden" />
            </form>
        </div>
        <div style="margin-top: 12px;">
            <script id="Editor" name="content" type="text/plain" style="width: 100%;">
            </script>
        </div>
    </div>
    <div style="width: 290px; background-color: rgb(95,143,220); position: absolute; right: 0px; top: 0px; bottom: 0px; padding: 12px;">
        <div class="am-panel am-panel-secondary">
            <div class="am-panel-hd">程序说明</div>
            <div class="am-panel-bd" style="font-size: 12px; line-height: 22px;">
                本程序只适用于博客园；<br />
                目前只提供了保存草稿的功能；<br />
                保存草稿的时候，会要求您输入博客园的用户名和密码；<br />
                您的用户名和密码DES加密之后保存在您本地的COOKIE里；<br />
                我的程序并不会把他们保存到数据库中；<br />
                程序只在UC浏览器下测试过（chrome内核）有问题可以反馈到我的博客里；<br />
            </div>
        </div>
        <div>
            <button id="GetBtn" type="button" class="am-btn am-btn-success rightBtn  am-radius">
                <i class="am-icon-retweet"></i>
                获取（最近一篇博客）
            </button>
            <button id="SaveBtn" type="button" class="am-btn am-btn-success rightBtn  am-radius">
                <i class="am-icon-floppy-o"></i>
                保存（默认到草稿箱）
            </button>
            <form class="am-form" accept-charset="GBK" action="https://shenghuo.alipay.com/send/payment/fill.htm" method="post" target="_blank">
                <input name="optEmail" type="hidden" value="412588801@qq.com">
                <input name="title" type="hidden" value="赞助博客园liulun一瓶啤酒">
                <input name="payAmount" type="hidden" value="3">
                <button type="submit" class="am-btn am-btn-warning rightBtn am-radius">
                    <i class="am-icon-coffee"></i>
                    赞助瓶啤酒
                </button>
            </form>
            <a class="am-btn am-btn-default rightBtn  am-radius" href="http://www.cnblogs.com/liulun" target="_blank">
                <i class="am-icon-rss"></i>
                作者的博客
            </a>
            <a data-type="3" data-tmpl="200x200" data-tmplid="197" data-rd="2" data-style="2" data-border="1" href="#"></a>
        </div>
    </div>
    <div class="am-modal am-modal-no-btn" tabindex="-1" id="blog-modal-login">
        <div class="am-modal-dialog">
            <div class="am-modal-hd" style="margin-bottom: 6px;">
                博客园用户信息
                <a href="javascript: void(0)" class="am-close am-close-spin" data-am-modal-close>&times;</a>
            </div>
            <div class="am-modal-bd">
                <div class="am-form am-form-horizontal">
                    <div class="am-form-group am-container">
                        <input id="ApiAddress" type="text" placeholder="MetaWeblog(博客园后台->设置页面最下方)">
                    </div>
                    <div class="am-form-group am-container">
                        <input id="UserName" type="text" placeholder="博客园的用户名">
                    </div>
                    <div class="am-form-group am-container">
                        <input id="PassWord" type="password" placeholder="博客园的密码">
                    </div>
                    <div class="am-g am-form-inline">
                        <div class="am-form-group  am-u-sm-6">
                            <div class="checkbox am-fl" style="margin-top: 8px;">
                                <label>
                                    <input id="RememberMe" type="checkbox" checked="checked">
                                    记住我
                                </label>
                            </div>
                        </div>
                        <div class="am-form-group  am-u-sm-6">
                            <div class="am-fr">
                                <button id="LoginBtn" type="button" class="am-btn am-btn-primary am-radius">提交并保存草稿</button>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>

    <div class="am-modal am-modal-loading am-modal-no-btn" tabindex="-1" id="loadingModal">
        <div class="am-modal-dialog">
            <div class="am-modal-hd" id="postAlertTitle">正在发往博客园，请稍后</div>
            <div class="am-modal-bd" id="postAlertInfo" style="padding-top: 20px;">
                <span class="am-icon-spinner am-icon-spin"></span>
            </div>
        </div>
    </div>
    <form id="form1" class="am-form" runat="server" style="margin: 0px; padding: 0px;">
    </form>
    <!-- shumanu.com Baidu tongji analytics -->
    <script type="text/javascript">
        var _bdhmProtocol = (("https:" == document.location.protocol) ? " https://" : " http://");
        document.write(unescape("%3Cscript src='" + _bdhmProtocol + "hm.baidu.com/h.js%3F9d58e4357ba7a260ce52bb6791a2aedd' type='text/javascript'%3E%3C/script%3E"));
    </script>
</body>
</html>
