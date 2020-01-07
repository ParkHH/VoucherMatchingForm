<%@page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@include file="/WEB-INF/jsp/common/include/PageHeader.jspf" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
<title>신청정보 조회</title>
<%@include file="/WEB-INF/jsp/common/include/HtmlHeader.jspf" %>
<script type="text/javascript">
    $(function() {
        if ("${param.APPL_DIV}"  == 'A') {
            <c:forEach var="codeGrpId001" items="${codeGrpId001}" varStatus="status">
            <c:forEach var="tbTceApplFieldList" items="${tbTceApplFieldList}" varStatus="status">
            <c:if test="${codeGrpId001.codeVal == tbTceApplFieldList.SUPP_FIELD}">
            $('#title_<c:out value="${codeGrpId001.codeVal}"/>').text("${codeGrpId001.codeName}");
            $('#<c:out value="${codeGrpId001.codeVal}"/>').show();
            </c:if>
            </c:forEach>
        </c:forEach>
        } else if ("${param.APPL_DIV}"  == 'B') {
            <c:forEach var="codeGrpId025" items="${codeGrpId025}" varStatus="status">
            $('#title_<c:out value="${codeGrpId025.codeVal}"/>').text("${codeGrpId025.codeName}");
            </c:forEach>
        }

         if("<c:out value="${rndInfo.VOUCH_ID}" />"  != "" ){
            $("#rndServiceWay").css("display", "block");

            if("<c:out value="${rndInfo.APPROV_STATUS}" />"  == "10" || "<c:out value="${rndInfo.APPROV_STATUS}" />"  == "90"){
                $("#btnRndRequest").css("display", "none");
            }else{
                $("#btnRndRequest").css("display", "none");
                $("#btnRndCancel").css("display", "none");
            }

            if("<c:out value="${rndInfo.SLCTN_DIV}" />"  != "1" ){
                $("#companyArea").css("display", "none");
                $("#fileArea").css("display", "none");
            }
        }else{
                $("#rndServiceWay").css("display", "none");
                $("#btnRndCancel").css("display", "none");
        }

         if("<c:out value="${viewMenuCode}" />" == "ICTP.BUSINESS"){
             $("#btnRndRequest").css("display", "none");
             $("#btnRndCancel").css("display", "none");
             $("#btnRndModify").css("display", "none");
         }
    });

    //팝업 닫기 이동
    function fnClose()
    {
        window.close();
    }

    // 관리자 저장 버튼
    function fnGoRndRequest()
    {
    	if (!confirm("<spring:message code="common.save.msg" text="#저장 하시겠습니까" javaScriptEscape="true" />")) return;
    	
    	var menuId;

	    if("<c:out value="${viewMenuCode}" />" == "MYPAGE.RNDAPPROV"){
	        menuId = "MYPAGE.RNDAPPROV";
	    }else{
	        menuId = "ICTP.VOUCHER.APPLYSTATE";
	    }
    	
    	var prx = any.proxy();
        prx.url("/rndmarket/voucher/updateVchInfoPasswd.do");
        prx.param("APP_NO", "<c:out value="${rndInfo.APP_NO}" />");
        prx.form('form[name="frm_main"]');
        prx.on("onSuccess", function() {
            alert("<spring:message code="success.common.process" text="#정상적으로 처리되었습니다." javaScriptEscape="true" />");
            if("<c:out value="${viewMenuCode}" />" == "ICTP.VOUCHER.APPLYSTATE"){
                window.location.href = "<c:url value="/rndmarket/voucher/getDetailApplyView.do" />?APP_NO="+<c:out value="${rndInfo.APP_NO}" />+"&MENU_ID="+menuId;
            }else{
                window.location.href = "<c:url value="/rndmarket/voucher/getApplyStateView.do" />";
            }
        });

        prx.on("onError", function() {
            this.error.show();
        });

       prx.execute();
    }
    //R&D 바우처 신청 취소
    function fnRndRequestCancel()
    {
        if(fnRetrieveGroup() > 0 ){
            alert("<spring:message code="rndmarket.info.msg.notCancel" text="#등록된 내역이 존재하여 취소처리 할 수 없습니다.\n관리자에게 문의 바랍니다." javaScriptEscape="true" />");
            return;
        }
        if (!confirm("<spring:message code="common.expert.cancel.msg" text="#신청취소하시겠습니까" javaScriptEscape="true" />")) return;

        var prx = any.proxy();
        prx.url("/rndmarket/mgmt/deleteRndInfo.do");
        prx.param('VOUCH_ID', "<c:out value="${rndInfo.VOUCH_ID}" />");
        prx.param('RFP_FILE_ID', "<c:out value="${rndInfo.RFP_FILE_ID}" />");
        prx.form('form[name="frm_main"]');

        prx.on("onSuccess", function() {
            alert("<spring:message code="success.expert.confirm.cancel" text="#정상적으로 취소되었습니다." javaScriptEscape="true" />");
            if("<c:out value="${viewMenuCode}" />" == "ICTP.APPROV"){
                window.location.href = "<c:url value="/techdb/enterprise/getDetailMyEntpROView.do" />?ENTP_ID="+"${entpInfo.ENTP_ID}&ENTP_MENU_ID=ICTP.APPROV";
            }else if("<c:out value="${viewMenuCode}" />" == "MYPAGE.RNDAPPROV"){
                window.location.href = "<c:url value="/techdb/enterprise/getDetailMyEntpROView.do" />?ENTP_ID="+"${entpInfo.ENTP_ID}&ENTP_MENU_ID=MYPAGE.RNDAPPROV";
            }else{
                window.location.href = "<c:url value="/techdb/enterprise/getDetailMyEntpROView.do" />?ENTP_ID="+"${entpInfo.ENTP_ID}";
            }
        });

        prx.on("onError", function() {
            this.error.show();
        });

       prx.execute();
    }

    //목록 화면 이동
    function fnGoList()
    {
    	window.location.href = "<c:url value="/rndmarket/voucher/getApplyStateView.do"/>";
    }


    function fnSelectEntpInfo(entpId)
    {
        window.opener.getReturnValue(entpId);
        self.close();
    }

    // 바우처 등록 내역 확인
    function fnRetrieveGroup()
    {
        var result = 0;
        $.ajax({
            async : false,
            type: "POST",
            url : "<c:url value="/rndmarket/mgmt/getSearchCreateVouchInfo.do" />",
            data: {'VOUCH_ID':"<c:out value="${rndInfo.VOUCH_ID}" />", 'SLCTN_DIV':"<c:out value="${rndInfo.SLCTN_DIV}" />"},
            success : function(data) {
                if( data["COUNT"] != null){
                    result =  data["COUNT"];
                    return result;
                }
            }
        });
        return result;
    }

    // 통보 메일 발송
    function fnSendMail()
    {
        if (!confirm("통보메일을 발송 하시겠습니까?")) return;
        
		var prx = any.proxy();
		prx.url("/rndmarket/approv/sendMailSingle.do");
		prx.param('VOUCH_ID', "<c:out value="${rndInfo.VOUCH_ID}" />");
		prx.param('ENTP_NAME', "<c:out value="${rndInfo.ENTP_NAME}" />");
		prx.form('form[name="frm_main"]');
		
		prx.on("onSuccess", function() {
		    alert("<spring:message code="success.common.process" text="#정상적으로 처리되었습니다." javaScriptEscape="true" />");
		});
		
		prx.on("onError", function() {
		    this.error.show();
		    });

	    prx.execute();
    }
</script>
</head>
<body>
<%@include file="/WEB-INF/jsp/common/include/BodyHeader.jspf" %>
<div id="wrap">
    <c:out value="${viewLayoutTop}" escapeXml="false" />
    <div id="container" class="sub">
        <c:out value="${viewLayoutLeft}" escapeXml="false" />
        <div id="subCon">
            <c:out value="${viewContentsHeader}" escapeXml="false" />
<form name="frm_main" method="post">
<input type="hidden" name="CHARGE_NAME" value="${entpInfo.CHARGE_NAME}">
<input type="hidden" name="CHARGE_TEL_NO" value="${entpInfo.CHARGE_TEL_NO}">
<input type="hidden" name="CHARGE_CELL_PHONE" value="${entpInfo.CHARGE_CELL_PHONE}">
<input type="hidden" name="CHARGE_MAIL_ADDR" value="${entpInfo.CHARGE_MAIL_ADDR}">
<input type="hidden" name="ENTP_ID" value="${entpInfo.ENTP_ID}">
        <!-- 컨텐츠 영역 시작-->
        <div class="pageContents">
           	<div class="btnAreaHead" id="btnArea">
           		<c:if test="${rndVchAuth == 'RNDADMIN'}">
           			<button type="button" class="btn btnBasic" id="btnRndRequest"  onclick="javascript:fnGoRndRequest(); return false;"><spring:message code="button.save" text="#저장" htmlEscape="true" /></button>
           		 </c:if>
           		 <button type="button" class="btn btnBasic" onclick="javascript:fnGoList(); return false;"><spring:message code="button.list" text="#목록" htmlEscape="true" /></button>
           	</div>
            
            <!-- 배장훈, A Section 기업정보  -->
            <c:if test="${rndVchAuth == 'RNDADMIN'}">
	            <div class="subSection" style="margin-bottom:10px; height:25px; line-height:25px; !important;">
					<span>기업정보</span>
	            </div>
	            
	            <table class="basicCon conboxTop" style="width:100%; table-layout:fixed;" >
	            	<tr>
	            		<th scope="row" style="width:18%;"><b>신청번호</b></th>
	            		<td style="padding-left:10px;">
	            			${rndInfo.APP_NO}
	            		</td>
	            		<th scope="row" style="width:18%;"><b>기업/기관명</b></th>
	            		<td style="padding-left:10px;">
	            			${rndInfo.ENTP_NAME}
	            		</td>
	            	</tr>
	            	<tr>
	            		<th scope="row" style="width:18%;"><b>사업자번호</b></th>
	            		<td style="padding-left:10px;">
	            			${rndInfo.BIZ_REG_NO}
	            		</td>
	            		<th scope="row" style="width:18%;"><b>법인등록번호</b></th>
	            		<td style="padding-left:10px;">
	            			${rndInfo.COR_NO}
	            		</td>
	            	</tr>
	            	<tr>
	            		<th scope="row" style="width:18%;"><b>대표자이름</b></th>
	            		<td style="padding-left:10px;">
	            			${rndInfo.CEO_NAME}
	            		</td>
	            		<th scope="row" style="width:15%;"><b>대표 연락처</b></th>
	            		<td style="padding-left:10px;">
	            			${rndInfo.COR_PHONE}
	            		</td>
	            	</tr>
	            	<tr>            		
	            		<th scope="row" style="width:18%;"><b>주소</b></th>            		
	            		<td colspan='3'>
	            			<table style="width:100%;">
	            				<tr>
	            					<td style="width:10%;">우편번호 : </td>
	            					<td style="padding-left:10px;">
	            						${rndInfo.POST_NO}
	            					</td>
	            				</tr>
	            				<tr>
	            					<td style="width:10%;">기본주소 : </td>
	            					<td style="padding-left:10px;">
	            						${rndInfo.BASE_ADDR}
	            					</td>
	            				</tr>
	            				<tr>
	            					<td style="width:10%;">상세주소 : </td>
	            					<td style="padding-left:10px;">
	            						${rndInfo.DTL_ADDR}
	            					</td>
	            				</tr>
	            			</table>
	            		</td>
	            	</tr>
	            	<tr>
	            		<th scope="row" style="width:18%;"><b>설립일</b></th>
	            		<td style="padding-left:10px;">
	            			${rndInfo.ENTP_DATE}
	            		</td>
	            		<th scope="row" style="width:15%;"><b>업종</b></th>
	            		<td style="padding-left:10px;">
	            			${rndInfo.ENTP_INDUTY}
	            		</td>
	            	</tr>
	            	<tr>
	            		<th scope="row" style="width:18%;"><b>상시종업원수(명)</b></th>
	            		<td style="padding-left:10px;">
	            			${rndInfo.EMP_CNT}
	            		</td>
	            		<th scope="row" style="width:15%;"><b>* 19년 매출액(억원)</b></th>
	            		<td style="padding-left:10px;">
	            			${rndInfo.SALES_PRICE}
	            		</td>
	            	</tr>
	            	<tr>
	            		<th scope="row" style="width:18%;"><b>주요제품/서비스</b></th>
	            		<td colspan='3'>
	            			${rndInfo.MAIN_PRODUCT}
	            		</td>
	            	</tr>
	            </table>
            </c:if>
            
            
            <!-- 배장훈, B Section 책임자정보 -->
            <c:if test="${rndVchAuth == 'RNDADMIN'}">
	            <div class="subSection" style="margin-bottom:10px; height:25px; line-height:25px; !important;">
					<span>책임자 정보</span>
	            </div>
	            
	            <table class="basicCon conboxTop" style="width:100%">
	            	<tr>
	            		<th scope="row" style="width:18%;"><b>책임자 이름</b></th>
	            		<td style="padding-left:10px;">
	            			${rndInfo.CHRG_NAME}
	            		</td>
	            		<th scope="row" style="width:18%;"><b>주민번호 앞자리</b></th>
	            		<td style="padding-left:10px;">
	            			${rndInfo.CHRG_SN}
	            		</td>
	            	</tr>
	            	<tr>
	            		<th scope="row" style="width:18%;"><b>부서</b></th>
	            		<td style="padding-left:10px;">
	            			${rndInfo.CHRG_DUTY}
	            		</td>
	            		<th scope="row" style="width:18%;"><b>직책</b></th>
	            		<td style="padding-left:10px;">
	            			${rndInfo.CHRG_DUTY}
	            		</td>
	            	</tr>
	            	<tr>
	            		<th scope="row" style="width:18%;"><b>책임자 휴대전화</b></th>
	            		<td style="padding-left:10px;">
	            			${rndInfo.CHRG_CELL_PHONE}
	            		</td>
	            		<th scope="row" style="width:18%;"><b>회사 연락처</b></th>
	            		<td style="padding-left:10px;">
	            			${rndInfo.CHRG_TEL_NO}
	            		</td>
	            	</tr>
	            	<tr>
	            		<th scope="row" style="width:18%;"><b>책임자 메일주소</b></th>
	            		<td colspan='3' style="padding-left:10px;">
	            			${rndInfo.CHRG_MAIL_ADDR}
	            		</td>
	            	</tr>
	            </table>
            </c:if>
            
            <!-- 배장훈, C Section 필요기술정보 -->
            <div class="subSection" style="margin-bottom:10px; height:25px; line-height:25px; !important;">
				<span>필요기술정보</span>
            </div>
            
            <table class="basicCon conboxTop" style="width:100%" id="applyList">
            	<tr>
            		<th scope="row" style="width:18%;"><b>과제명</b></th>
            		<td colspan='3' style="padding-left:10px;">
            			${rndInfo.PJT_NAME}
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%;"><b>부출연금(백만원)</b></th>
            		<td style="padding-left:10px;">
            			${rndInfo.TOT_GVRN_CNBN}
            		</td>
            		<th scope="row" style="width:18%;"><b>참여기관</b></th>
            		<td style="padding-left:10px;">
            			${rndInfo.PART_INST_NAME}
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%;"><b>바우처 지원 필요성</b><b><br>(500자)</b></th>
                    <td colspan="3" style="padding-left:10px;">
                          <div style="overflow: auto;" >
                                <xmp><c:out value="${rndInfo.VOUCH_NEEDS}" /></xmp>
                           </div>
                    </td>
            	</tr>
            	<tr> 
            		<th scope="row" style="width:18%;"><b>필요기술명</b></th>
            		<td colspan='3' style="padding-left:10px;">
            			${rndInfo.TECH_NEEDS}
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%;"><b>필요기술의 설명 및 <br>목표 성능치</b><b><br>(500자)</b></th>
                    <td colspan="3" style="padding-left:10px;">
                          <div style="overflow: auto;" >
                                <xmp><c:out value="${rndInfo.TECH_DESC}" /></xmp>
                           </div>
                    </td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%;"><b>필요기술의 설명 및 <br>사업화 계획</b><b><br>(500자)</b></th>
                    <td colspan="3" style="padding-left:10px;">
                          <div style="overflow: auto;" >
                                <xmp><c:out value="${rndInfo.TECH_PLAN}" /></xmp>
                           </div>
                    </td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%;"><b>기타요구사항<br>(500자)</b></th>
                    <td colspan="3" style="padding-left:10px;">
                          <div style="overflow: auto;" >
                                <xmp><c:out value="${rndInfo.REQ_ITEMS}" /></xmp>
                           </div>
                    </td>
            	</tr>
            	<c:if test="${rndVchAuth == 'RNDADMIN'}">
            	<tr>
            		<th scope="row" style="width:18%"><b>매칭신청서</b>            	
            		<td colspan='3' style="padding-left:10px;">
            			<c:if test="${rndInfo.ATTACH_FILE_ID != '' }">
            				<a href="https://172.16.4.84/IITP_ICT-bay/download/${rndInfo.ATTACH_FILE_ID }" target="_blank">${rndInfo.ATTACH_FILE_ID }</a>
            			</c:if>
            		</td>
            	</tr>
            	</c:if>
            	<tr>
            		<td colspan='4'>
            			<span><b style="color:red">* </b><b>매칭신청서 내용(필요 기술정보)은 연구자/연구기관 탐색 및 매칭을 위해 공개됨을 동의합니다</b></span>
            			<input type="checkbox" name="ckb_agree"
            					<c:if test="${rndInfo.INFO_AGREE_YN == 'Y'}">checked</c:if>
            			> 
            			<br>
            			&nbsp;&nbsp;&nbsp;&nbsp;<span><b>(기업정보 및 책임자 정보는 공개되지 않습니다.)</b></span>
            		</td>
            	</tr>
            	<c:if test="${rndVchAuth == 'RNDADMIN'}">
            		<tr>
            			<th scope="row" style="width:18%;"><b>비밀번호</b></th>
	            		<td colspan='3' style="padding-left:10px;">
	            			<input type="password" name="applyList.DOC_PASS" style="width:98%;" value="${rndInfo.DOC_PASS}"/>
	            		</td>
            		</tr>
           		</c:if>
            </table>
            
            
        </div>
</form>

        </div>
    </div>
</div>

<c:out value="${viewLayoutBottom}" escapeXml="false" />

<%@include file="/WEB-INF/jsp/common/include/BodyFooter.jspf" %>
</body>
</html>
