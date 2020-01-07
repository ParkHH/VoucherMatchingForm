<%@page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@include file="/WEB-INF/jsp/common/include/PageHeader.jspf" %>
<!DOCTYPE html>
<html>
<head>
<title>기업 매칭 지원 신청현황</title>
<%@include file="/WEB-INF/jsp/common/include/HtmlHeader.jspf" %>
<script type="text/javascript" src="<c:url value='/ui/js/comment.js'/>" ></script>
<script type="text/javascript" charset="utf-8" src="<c:out value="${pageContext.request.contextPath}/ui/jquery/jquery-ui-1.10.3.custom.js" />"></script>
<script type="text/javascript">

	// 체크박스 전체선택
	$(function() {
	    $('button[command="retrieve"]').click(function() {
	        fnRetrieve();
	    });
	
	    $('input.checkBoxAll').each(function(){
	        $(this).click(function(){
	            var $check = $('input[type=checkbox]');
	            if($(this).prop('checked') == true){
	                $check.prop('checked',true);
	            } else {
	                $check.prop('checked',false);
	            }
	        });
	    });
	});
	
	// 조회
	function fnRetrieve(currentPageNo)
	{
	   cfRetrieveList("frm_main", currentPageNo);
	}
	
	//상세 조회
	function fnDetailView(app_no)
	{
	    var menuId;

	    if("<c:out value="${viewMenuCode}" />" == "MYPAGE.RNDAPPROV"){
	        menuId = "MYPAGE.RNDAPPROV";
	    }else{
	        menuId = "ICTP.VOUCHER.APPLYSTATE";
	    }
	    window.location.href ="<c:url value="/rndmarket/voucher/getDetailApplyView.do" />?APP_NO="+app_no+"&MENU_ID="+menuId;
	}
 
    //목록 화면 이동
    function fnGoList()
    {
        /* window.location.href = "<c:url value="/techdb/enterprise/getMyEntpListView.do" />"; */
        history.back(1);
    }

    //수정화면 이동
    function fnModify(){

        window.location.href = "<c:url value="/techdb/enterprise/getViewMyEntp.do" />?ENTP_ID="+"${entpInfo.ENTP_ID}"+"&view=";
    }
    function fnSelectEntpInfo(entpId)
    {
        window.opener.getReturnValue(entpId);
        self.close();
    }
    
  	//처리 가능 건수 체크
    function cntCheckBox(status){
        var cnt = 0;
        $('input[name=ChkApprovNm]').each(function(idx){
            if($(this).prop('checked') == true){
                var chkId = $(this).attr("id");
                if($("#"+chkId+"_status").val() != status){cnt++;}
            }
        });

        return cnt;
    }
    
 	// 승인 반려 처리
    function fnGoApproval()
    {
    	if(!$('input[type=checkbox]').is(":checked")){
            alert("<spring:message code="tcexpress.support.msg.noSelect" text="#선택된 건이 없습니다." htmlEscape="true" />");
            return;
        }
    	
	   	// $('select.selectItem').each(function(){
	   	//        alert($(this).val());
	   	//    });
 		
 		
        if(!$('input[type=checkbox]').is(":checked")){
            alert("<spring:message code="tcexpress.support.msg.noSelect" text="#선택된 건이 없습니다." htmlEscape="true" />");
            return;
        }
        
        $('input[name=ChkApprovNm]').each(function(){
            if($(this).prop('checked') != true){
                var tdId = $(this).attr("id");
                $("#"+tdId+"_td").remove();
            }
        });
        

        if (!confirm("<spring:message code="common.save.msg" text="#저장 하시겠습니까" javaScriptEscape="true" />")) return;
       
        var prx = any.proxy();
        prx.url("/rndmarket/voucher/getApprovUpdate.do");
        prx.form('form[name="frm_main"]');
        prx.on("onSuccess", function() {
            alert("<spring:message code="success.common.process" text="#정상적으로 처리되었습니다." javaScriptEscape="true" />");
            if("<c:out value="${viewMenuCode}" />" == "MYPAGE.RNDAPPROV"){
                window.location.href = "<c:url value="/rndmarket/voucher/getApplyStateView.do" />?MENU_ID=ICTP.VOUCHER.APPLYSTATE";
            }else{
                window.location.href = "<c:url value="/rndmarket/voucher/getApplyStateView.do" />";
            }
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
<form name="frm_main" method="post" onEnter="javascript:fnRetrieve()">
<div id="wrap">

    <c:out value="${viewLayoutTop}" escapeXml="false" />

    <div id="container" class="sub">
        <c:out value="${viewLayoutLeft}" escapeXml="false" />

        <div id="subCon">
            <c:out value="${viewContentsHeader}" escapeXml="false" />

        <!-- 컨텐츠 영역 시작-->
        <div class="pageContents">
       		<c:if test="${rndVchAuth == 'RNDADMIN'}">
                 <div class="btnAreaMiddle">
                  <button type="button" class="btn btnBasic" onclick="javascript:fnGoApproval();"><spring:message code="button.save" text="#저장" htmlEscape="true" /></button>
                 </div>
            </c:if>
        
        	<!-- 상단 테이블 -->
        	<table class="basicCon conboxType3">
	             <colgroup>
	                 <col width="20%">
	                 <col width="30%">
	                 <col width="20%">
	                 <col width="30%">
	                 <col width="120px">
	             </colgroup>
	             <tr>
	                 <th><spring:message code="rndmarket.info.label.serviceComp" text="#기업명" htmlEscape="true" /></th>
	                 <td colspan="3">
	                     <input type="text" name="rndInfo.ENTP_NAME" value="<c:out value="${rndInfo.ENTP_NAME}" />">
	                 </td>
	                 <td rowspan="4" class="btnSh">
	                     <button type="button" class="btn" command="retrieve"><spring:message code="button.inquire" text="#조회" htmlEscape="true" /></button>
	                 </td>
	            </tr>
	            <tr>
	                 <th><spring:message code="rndmarket.info.label.techName" text="#기술명" htmlEscape="true" /></th>
	                 <td colspan="3">
	                     <input type="text" name="rndInfo.TECH_NEEDS" value="<c:out value="${rndInfo.TECH_NAME}" />">
	                 </td>
	            </tr>
	            <tr>
	                 <th><spring:message code="rndmarket.info.label.appNo" text="#신청번호" htmlEscape="true" /></th>
	                 <td colspan="3">
	                     <input type="text" name="rndInfo.APP_NO" value="<c:out value="${rndInfo.APP_NO}" />">
	                 </td>
	            </tr>
	            <tr>
	                 <th><spring:message code="rndmarket.info.label.progStatus" text="#단계" htmlEscape="true" /></th>
	                 <td colspan="3">
                         <select name="rndInfo.DOC_STATUS" class="select" title="#승인상태">
                             <option value=""><spring:message code="label.all" text="#(전체)" htmlEscape="html" /></option>
                             <c:forEach var="rndStatus" items="${rndStatus}" varStatus="status">
                                 <option value="${rndStatus.codeVal}"<c:if test="${rndInfo.DOC_STATUS == rndStatus.codeVal }">selected="selected"</c:if>><c:out value="${rndStatus.codeName}"/></option>
                             </c:forEach>
                         </select>
                     </td>
	             </tr>
	         </table>
	         
	         <%@include file="/WEB-INF/jsp/common/include/ListHeader.jspf" %>

            <table class="basicCon conboxTop conboxType2" summary="" id="applyList">
                    <caption><spring:message code="sysmgt.menumgt.title.list" text="#메뉴 목록" htmlEscape="true" /></caption>
                    <colgroup>
                        <col width="5%">
                        <col width="7%">
                        <col width="15%">
                        <col width="22%">
                        <col width="23%">
                        <col width="16%">
                        <col width="12%">
                    </colgroup>
                    <thead sortingInfo="<c:out value="${sortingInfo}" />">
                        <tr>
                            <th><input type="checkbox" class="checkBoxAll"></th>
                            <th><spring:message code="label.no" text="#번호" htmlEscape="true" /></th>
                            <th><spring:message code="rndmarket.info.label.appNo" text="#신청번호" htmlEscape="true" /></th>
                            <th listSortName="ENTP_NAME"><spring:message code="rndmarket.info.label.serviceComp" text="#기업명" htmlEscape="true" /></th>
                            <th listSortName="CHARGE_NAME"><spring:message code="rndmarket.info.label.techName" text="#기술명" htmlEscape="true" /></th>
                            <th listSortName="CRE_DATETIME"><spring:message code="rndmarket.info.label.rndRegDate" text="#신청일자" htmlEscape="true" /></th>
                            <th><spring:message code="rndmarket.info.label.processStatus" text="#진행현황" htmlEscape="true" /></th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:if test="${not empty applyList}">
                        <c:forEach var="listInfo" items="${applyList}" varStatus="status">
                        <tr id="rndInfo_${status.index}">
                            <td class="conCenter">
                                <input class="conCenter" type="checkbox" name="ChkApprovNm" id="ChkApprov_${status.index}" >
                            </td>
                            <td><b><c:out value="${listInfo.RNDESC}"/></b></td>
                            <td class="conCenter"><c:out value="${listInfo.APP_NO}" /></td>
                            <td class="conLeft01"><c:out value="${listInfo.ENTP_NAME}" /></td>
                            <td class="conLeft01" title="<c:out value="${listInfo.TECH_NEEDS}" />">
                            
                                <c:if test="${sessionScope.loginUserVO.personDiv eq 'I'}">
                                   <a href="#" onclick="javascript:fnDetailView('${listInfo.APP_NO}');"><c:out value="${listInfo.TECH_NEEDS}" /></a>
                                </c:if>
                                <c:if test="${sessionScope.loginUserVO.personDiv ne 'I'}">
                                   <c:out value="${listInfo.TECH_NEEDS}" />
                                </c:if>
                            </td>
                            <td class="conCenter"><c:out value="${listInfo.CRE_DATETIME}" /></td>
                            <td class="conCenter">
                            	<c:if test="${rndVchAuth == 'RNDADMIN'}">
	                            	<select name="applyList.DOC_STATUS" class="selectItem" title="#승인상태">
		                            		<c:forEach var="rndStatus" items="${rndStatus}" varStatus="status">
		                            			<option value="${rndStatus.codeVal}"
		                            				<c:if test="${listInfo.DOC_STATUS == rndStatus.codeVal }">selected="selected"</c:if>>
		                            				<c:out value="${rndStatus.codeName}"/>
	                            				</option>
		                            		</c:forEach>
		                         	</select>
		                         </c:if>
		                         <c:if test="${rndVchAuth != 'RNDADMIN'}">
                           				<c:if test="${listInfo.DOC_STATUS == '01'}">작성중</c:if>
                           				<c:if test="${listInfo.DOC_STATUS == '02'}">작성완료</c:if>
                           				<c:if test="${listInfo.DOC_STATUS == '03'}">제출완료</c:if>
                           				<c:if test="${listInfo.DOC_STATUS == '04'}">접수완료</c:if>
                           				<c:if test="${listInfo.DOC_STATUS == '05'}">보완요청</c:if>
                           				<c:if test="${listInfo.DOC_STATUS == '06'}">검토중</c:if>
                           				<c:if test="${listInfo.DOC_STATUS == '07'}">매칭완료</c:if>
		                         </c:if>
		                         
                            </td>
                            <td style="display: none;" id="ChkApprov_${status.index}_td">
                        	    <input type="hidden" name="applyList.APP_NO" value="<c:out value="${listInfo.APP_NO}" />">
                                <!-- <input type="hidden" id="ChkApprov_${status.index}_status" name="applyList.DOC_STATUS" value="<c:out value="${listInfo.DOC_STATUS}" />"> -->
                            </td>
                        </tr>
                        </c:forEach>
                        </c:if>
                        <c:if test="${empty applyList}">
                        <tr id="approvListEmpty">
                            <td colspan="8" style="text-align: center;">(<spring:message code="techdb.common.noData" text="#no Data" htmlEscape="true" />)</td>
                        </tr>
                        </c:if>
                    </tbody>
                </table>

              <%@include file="/WEB-INF/jsp/common/include/ListFooter.jspf" %>
        </div>
        </div>
    </div>
</div>

<c:out value="${viewLayoutBottom}" escapeXml="false" />
</form>

<%@include file="/WEB-INF/jsp/common/include/BodyFooter.jspf" %>
</body>
</html>
