<%@page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@include file="/WEB-INF/jsp/common/include/PageHeader.jspf" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<title>기술 매칭 지원 신청</title>
<%@include file="/WEB-INF/jsp/common/include/HtmlHeader.jspf" %>
<script type="text/javascript" src="<c:url value='/ui/js/comment.js'/>" ></script>
<script type="text/javascript" charset="utf-8" src="<c:out value="${pageContext.request.contextPath}/ui/jquery/jquery-ui-1.10.3.custom.js" />"></script>
<script type="text/javascript">
	$(function(){
		$("input[name='bt_newApplyDo']").click(function(){
			newApply();
		});
		$("input[name='bt_inquireDo']").click(function(){
			inquire();
		});
	});
	
	// 신규 신청 버튼
	function newApply(){
		if(!confirm("신규 신청을 진행하시겠습니까?")){
			return;
		}
		
		$("input[name='next_or_prev']").val("next");
		$("input[name='DOC_STATUS']").val("01");
		$("input[name='BIZ_REG_NO']").val("");
		$("input[name='APP_NO']").val("");
		
		$("form[name='searchParamForm']").attr({
			action:"/rndmarket/voucher/getApplyView.do",
			method:"get"
		});
		$("form[name='searchParamForm']").submit();
		
		//location.href="/rndmarket/voucher/getApplyView.do?next_or_prev=next&DOC_STEP=00";
	}
	
	// inquire 버튼
	function inquire(){
		var loginId = $("input[name='loginId']").val();																	// 로그인 아이디
		var BIZ_REG_NO_FRONT = $("input[name='input_business_no_front']").val();								// 사업자번호(앞) *
		var BIZ_REG_NO_MID = $("input[name='input_business_no_mid']").val();									// 사업자번호(중간) *
		var BIZ_REG_NO_REAR = $("input[name='input_business_no_rear']").val();								// 사업자번호(끝) *
		var BIZ_REG_NO = BIZ_REG_NO_FRONT+'-'+BIZ_REG_NO_MID+'-'+BIZ_REG_NO_REAR;				// 사업자번호
		var APP_NO = $("input[name='input_matching_apply_number']").val();									// 매칭 신청 번호
		var password = $("input[name='input_password']").val();													// 비밀번호
		
		$("input[name='BIZ_REG_NO']").val(BIZ_REG_NO);
		$("input[name='APP_NO']").val(APP_NO);
		
		// 신청 이력이 존재하는지 판단하여 결과에 따라 다른 안내문구 출력
		$.ajax({
			url:"/rndmarket/voucher/getApplyHistory.do",
			type:"get",
			data:{
				APP_NO : APP_NO
			},
			success:function(result){
				var json = JSON.parse(result);
				var vouchers = json.vouchers;
				var voucherCount = vouchers.length;
				
				// 조회 건수가 0 이라면 신규작성 여부 확인 
				if(voucherCount==0){
					if(!confirm("신청현황이 없습니다. 신규 작성하시겠습니까?")){
						return;
					}
					location.href="/rndmarket/voucher/getApplyView.do";
				}
				
				// 조회건수가 1개 이상이라면 매칭 신청 번호 및 비밀번호 check
				for(var i=0; i<voucherCount; i++){
					var voucher = vouchers[i];
					var voucherMatchingNum = voucher.APP_NO;
					var voucherPass = voucher.DOC_PASS;
					
					if(voucherMatchingNum == APP_NO && voucherPass == password){
						var applyStatus = voucher.DOC_STATUS;
						var doc_step = voucher.DOC_STEP;
						$("input[name='DOC_STATUS']").val(applyStatus);
						//alert($("input[name='DOC_STATUS']").val());
						
						if(applyStatus=="01"){
							if(!confirm("기존 작성 내역이 존재합니다.")){
								return;
							}
							$("form[name='searchParamForm']").attr({
								action:"/rndmarket/voucher/getApplyViewStatus.do",
								method:"get"
							});
						}else if(applyStatus == "02" || applyStatus == "03" || applyStatus == "04" || applyStatus == "05" || applyStatus == "07"){
							$("form[name='searchParamForm']").attr({
								action:"/rndmarket/voucher/getApplyView3.do",
								method:"get"
							});
						}else if(applyStatus == "06"){
							$("form[name='searchParamForm']").attr({
								action:"/rndmarket/voucher/getApplyViewStatus.do",
								method:"get"
							});
						}
						$("form[name='searchParamForm']").submit();
						break;
					}else{
						if(voucherMatchingNum != APP_NO && voucherPass == password ) {
							alert("매칭신청번호를 확인 바랍니다.");
							return;
						}
						
						if(voucherMatchingNum == APP_NO && voucherPass != password){
							alert("비밀번호가 틀렸습니다. 다시 확인하고 조회하세요");
							return;
						}
					}
				}
			}
		});
	}
</script>
</head>

<body>

<%@include file="/WEB-INF/jsp/common/include/BodyHeader.jspf" %>

<form name="frm_main">

<input type="hidden" id="RETURN_SUBJECT">
<input type="hidden" id="RETURN_REASON">

<div id="wrap">
    <c:out value="${viewLayoutTop}" escapeXml="false" />

    <div id="container" class="sub">
        <c:out value="${viewLayoutLeft}" escapeXml="false" />
		
        <div id="subCon" style="width:80%;">
            <c:out value="${viewContentsHeader}" escapeXml="false" />
		
			<div id="buttonDiv" style="width:100%; height:30%; text-align:right; margin-bottom:10px;">
				<input type="button" name="bt_newApplyDo"  class="btn btnBasic" style="width:13%; height:30px; font-size:25px;" value="신규신청"/>
			</div>
			<div id="infoDiv" style="width:100%; height:25px; padding-top:10px; border-top:1px solid dodgerblue; border-bottom:1px solid dodgerblue;">
				<span style="color:dodgerblue">
					<b>* 매칭 신청 내역 검색은 아래 현황 확인 검색을 통해 확인하시고 처음 신규 등록을 원하시면 신규 신청을 통해 진행하세요.</b><br>
				</span>
			</div>
			
			<div class="subSection" style="margin-bottom:10px; height:25px; line-height:25px; !important;">
				<span>매칭 신청 현황 확인</span>
            </div>
            
            <table class="basicCon conboxType3" style="width:100%">
         		<tr>
            		<th scope="col" style="width:15%;"><b>사업자등록번호</b></th>
            		<td style="padding-left:10px;">
            			<input type="text" name="input_business_no_front" style="width:8%;" maxlength=3/> <b>-</b>
            			<input type="text" name="input_business_no_mid" style="width:4%;" maxlength=2/> <b>-</b>
            			<input type="text" name="input_business_no_rear" style="width:15%;" maxlength=5/>
            		</td>
            	</tr>
            	<tr>
            		<th scope="col" style="width:15%;"><b>매칭 신청 번호</b></th>
            		<td style="padding-left:10px;">
            			<input type="text" name="input_matching_apply_number" style="width:80%;"/>
            			<input type="button" name="bt_inquireDo" style="width:13%; height:25px; background:black; color:white; font-weight:bold; font-size:15px; border-radius:5px;" value="Inquire"/>
            		</td>
            	</tr>
            	<tr>
            		<th scope="col" style="width:15%;"><b>비밀번호</b></th>
            		<td style="padding-left:10px;">
            			<input type="password" name="input_password" style="width:95%;"/>
            		</td>
            	</tr>
            </table>
    </div> 
</div>

<c:out value="${viewLayoutBottom}" escapeXml="false" />
</form>


<form name="searchParamForm">
	<input type="hidden" name="next_or_prev" value="none">
	<input type="hidden" name="DOC_STEP" value="00">
	<input type="hidden" name="DOC_STATUS" value="">
	<input type="hidden" name="BIZ_REG_NO" value="">
	<input type="hidden" name="APP_NO" value="">

</form>

<%@include file="/WEB-INF/jsp/common/include/BodyFooter.jspf" %>

</body>
</html>
