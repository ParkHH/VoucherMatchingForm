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
		$("input[name='bt_prev']").click(function(){
			goPrevPage();
		});
		$("input[name='bt_next']").click(function(){
			next();
		});
		$("input[name='bt_reset']").click(function(){
			contentReset();
		});
	});
	
	
	//파일 저장
	function fnSave(){
		var form = $("form[name='frm_main']")[0];
		var formData = new FormData(form);
		formData.append("message", "매칭신청서 upload");
		formData.append("choose_files", $("input[name='choose_files']")[0].files[0]);
		$.ajax({
			url:"/rndmarket/voucher/fileUpload.do",
			data:formData,
			processData:false,
			contentType:false,
			type:"post",
			success:function(result){
				alert(result);
				var json = JSON.parse(result);
				var result = json.result;
				if(result>0){
					alert("파일 업로드 성공");				
				}else{
					alert("파일 업로드 실패");
				}
			}
		});
		/*
		$("form[name='frm_main']").attr({
			action:"/rndmarket/voucher/fileUpload.do",
			method:"post"
		});
		$("form[name='frm_main']").submit();
		*/
	}
	
	
	// 이전 버튼
	function goPrevPage(){
		$("input[name='next_or_prev']").val("prev");
		$("form[name='voucherApplyForm2']").attr({
			action:"/rndmarket/voucher/getApplyView.do",
			method:"get"
		});
		$("form[name='voucherApplyForm2']").submit();
	}
	
	
	
	// 다음버튼
	function next(){
		$("input[name='next_or_prev']").val("next");																		// 페이지 이동 동작상태를 next 로
		
		var PJT_NAME = $("input[name='input_project_name']").val();												// 과제명 *
		var TOT_GVRN_CNBN = $("input[name='input_goverment_price']").val();								// 정부출연금
		var PART_INST_NAME = $("input[name='input_present_association']").val();							// 참여기관 
		var VOUCH_NEEDS = $("textarea[name='input_need_voucher']").val();									// 바우처지원 필요성 *
		var TECH_NEEDS = $("input[name='input_need_tech_name']").val();										// 필요기술명 *
		var TECH_DESC = $("textarea[name='input_need_tech_descript']").val();								// 필요기술의 설명 및 목표 성능치 *
		var TECH_PLAN = $("textarea[name='input_need_tech_plan']").val();									// 필요기술이 적용될 제품 및 사업화계획 *
		var REQ_ITEMS = $("textarea[name='input_another_request']").val();									// 기타요구사항
		var choose_files = $("input[name='choose_files']")[0].files;											// 기술제안서 *
		var ATTACH_FILE_ID = null;
		var INFO_AGREE_YN = null;																							// 동의 여부
		var USER_ID = $("input[name='loginId']").val();																	// 작성자 아이디
		
		
		for(var i=0; i<choose_files.length; i++){
			ATTACH_FILE_ID = choose_files[i].name;
		}
		
		var elements = new Array();
		elements[0] = PJT_NAME;
		elements[1] = VOUCH_NEEDS;
		elements[2] = TECH_NEEDS;
		elements[3] = TECH_DESC;
		elements[4] = TECH_PLAN;
		elements[5] = ATTACH_FILE_ID;
		
		for(var i=0; i<elements.length; i++){
			var element = elements[i];
			if(element == "" || element == null){
				alert("필수항목 입력사항을 확인하세요.");
				return;
			}
		}
		
		fnSave();
		
		var checkedState = $("input[name='ckb_agree']").is(":checked");		// 동의 checkbox *
		if(!checkedState){
			alert("동의 여부를 확인해주세요.");
			return;
		}else{
			INFO_AGREE_YN='Y';
		}
		
		$("input[name='PJT_NAME']").val(PJT_NAME);
		$("input[name='TOT_GVRN_CNBN']").val(TOT_GVRN_CNBN);
		$("input[name='PART_INST_NAME']").val(PART_INST_NAME);
		$("input[name='VOUCH_NEEDS']").val(VOUCH_NEEDS);
		$("input[name='TECH_NEEDS']").val(TECH_NEEDS);
		$("input[name='TECH_DESC']").val(TECH_DESC);
		$("input[name='TECH_PLAN']").val(TECH_PLAN);
		$("input[name='REQ_ITEMS']").val(REQ_ITEMS);
		$("input[name='ATTACH_FILE_ID']").val(ATTACH_FILE_ID);
		$("input[name='INFO_AGREE_YN']").val(INFO_AGREE_YN);
		$("input[name='USER_ID']").val(USER_ID);
		
		
		$("form[name='voucherApplyForm2']").attr({
			action:"/rndmarket/voucher/getApplyView3.do",
			method:"post"
		});
		$("form[name='voucherApplyForm2']").submit();
	
	}
	
	
	// 파일 다운로드
	function fileDown(){
		var APP_NO = $("input[name='APP_NO']").val();
		location.href = "/rndmarket/voucher/fileDownload.do?APP_NO=vm0000-000";
		/*
		$.ajax({
			url:"/rndmarket/voucher/fileDownload.do",
			type:"get",
			data:{
				APP_NO:$("input[name='APP_NO']").val()
			},
			success:function(result){
				alert("파일을 다운로드 합니다.");
			}
		});
		*/
	}
</script>
</head>

<body>

<%@include file="/WEB-INF/jsp/common/include/BodyHeader.jspf" %>

<form name="frm_main" enctype="multipart/form-data">

<input type="hidden" id="RETURN_SUBJECT">
<input type="hidden" id="RETURN_REASON">
<input type="hidden" name="APP_NO" value="${APP_NO}">

<div id="wrap">
    <c:out value="${viewLayoutTop}" escapeXml="false" />

    <div id="container" class="sub">
        <c:out value="${viewLayoutLeft}" escapeXml="false" />
		
        <div id="subCon" style="width:100%;">
            <c:out value="${viewContentsHeader}" escapeXml="false" />
			
			<div id="bannerDiv_front" style="width:100%; height:90px; margin-bottom:10px;">
				<img src="/images/voucher_matching/images/vm_appl_step02.gif" style="width:90%; height:100%;"/>
			</div>
			<div id="buttonDiv" style="width:100%; height:30%; text-align:right; margin-bottom:10px;">
				<input type="button" name="bt_prev"  class="btn btnBasic" style="width:8%; height:30px; font-size:25px;" value="이전"/>
				<input type="button" name="bt_next"  class="btn btnBasic" style="width:8%; height:30px; font-size:25px;" value="다음"/>
			</div>
			<div id="infoDiv" style="width:100%; height:70px; padding-top:10px; border-top:1px solid dodgerblue; border-bottom:1px solid dodgerblue;">
				<table style="width:100%;">
				<tr style="height:30px;">
					<td>
						<span style="color:dodgerblue"><b>* '매칭신청서' 양식은 IITP 공고화면에서도 다운로드가 가능합니다</b></span>
					</td>
					<td style="text-align:right; padding-right:10px; font-size:20px; font-weight:bold; color:red;">
						<a href="javascript:fileDown();" style="font-size:15px; font-weight:bold; color:orange;">매칭 신청서 양식.hwp</a>
					</td>
				</tr>
				<tr style="height:30px;">
					<td colspan='2'>
						<span style="color:dodgerblue"><b>* 붉은색 별표는 필수 입력 사항입니다.</b></span><br><br>
					</td>
				</tr>
				<!-- <input type="hidden" attach-file name="mainInfo.ATTACH_FILE_ID" value="75E2DQUFL04REYS000" readOnly/> -->
				</table>
			</div>
			
			<div class="subSection" style="margin-bottom:10px; height:25px; line-height:25px; !important;">
				<span>필요기술정보</span>
            </div>
            
            <table class="basicCon conboxTop" style="width:100%">
            	<tr>
            		<th scope="row" style="width:18%;"><b>과제명</b><b style="color:red;"> *</b></th>
            		<td colspan='3' style="padding-left:10px;">
            			<input type="text" name="input_project_name" style="width:99.5%;" value="${voucherJSON.PJT_NAME}"/>
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%;"><b>정부출연금(백만원)</b></th>
            		<td style="padding-left:10px;">
            			<input type="text" name="input_goverment_price" style="width:98%;" value="${voucherJSON.TOT_GVRN_CNBN}"/>
            		</td>
            		<th scope="row" style="width:18%;"><b>참여기관</b></th>
            		<td style="padding-left:10px;">
            			<input type="text" name="input_present_association" style="width:98%;" value="${voucherJSON.PART_INST_NAME}"/>
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%;"><b>바우처지원 필요성</b><b style="color:red;"> *</b><b><br>(500자)</b><b style="color:red;"> *</b></th>
            		<td  colspan='3' style="padding-left:10px;">
            			<textarea rows="4" cols="10" name="input_need_voucher" maxlength="500">${voucherJSON.VOUCH_NEEDS}</textarea>
            		</td>           
            	</tr>
            	<tr>            		
            		<th scope="row" style="width:18%;"><b>필요기술명</b><b style="color:red;"> *</b></th>            		
            		<td colspan='3'>
            			<input type="text" name="input_need_tech_name" style="width:99.5%;" value="${voucherJSON.TECH_NEEDS}"/>
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%;"><b>필요기술의 설명 및 <br>목표 성능치</b><b style="color:red;"> *</b><br><b>(500자)</b></th>
            		<td colspan='3' style="padding-left:10px;">
            			<textarea rows="4" cols="10" name="input_need_tech_descript" maxlength="500">${voucherJSON.TECH_DESC}</textarea>
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%;"><b>필요기술이 적용될 제품 및<br> 사업화 계획</b><b style="color:red;"> *</b><br><b>(500자)</b></th>
            		<td colspan='3' style="padding-left:10px;">
            			<textarea rows="4" cols="10" name="input_need_tech_plan" maxlength="500">${voucherJSON.TECH_PLAN}</textarea>
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%;"><b>기타요구사항<br>(500자)</b></th>
            		<td colspan='3' style="padding-left:10px;">
            			<textarea rows="4" cols="10" name="input_another_request" maxlength="300">${voucherJSON.REQ_ITEMS}</textarea>
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%"><b>기술제안서</b><b style="color:red;"> *</b><!--<spring:message code="cop.atchFile"/>-->
            		<td colspan='3'>
            			<input type="file" name="choose_files"  style="width:100%; height:20px;"/>
            			<!-- <input type="hidden" attach-file name="maininfo.ATTACH_FILE_ID"  style="width:100%; height:20px;" value="choose File"/> -->
            		</td>
            	</tr>
            	<tr>
            		<td colspan='4'>
            			<span><b style="color:red">* </b><b>매칭신청서 내용(필요 기술정보)은 연구자/연구기관 탐색 및 매칭을 위해 공개됨을 동의합니다</b></span>
            			<input type="checkbox" name="ckb_agree"/><br>
            			&nbsp;&nbsp;&nbsp;&nbsp;<span><b>(기업정보 및 책임자 정보는 공개되지 않습니다.)</b></span>
            		</td>
            	</tr>
            </table>
            
            <div id="buttonDiv_rear" style="width:100%; height:30%; text-align:right; margin-top:20px;">
				<input type="button" name="bt_prev"  class="btn btnBasic" style="width:8%; height:30px; font-size:25px;" value="이전"/>
				<input type="button" name="bt_next"  class="btn btnBasic" style="width:8%; height:30px; font-size:25px;" value="다음"/>
			</div>
    </div> 
</div>
<c:out value="${viewLayoutBottom}" escapeXml="false" />
</form>

<form name='voucherApplyForm2'>
	<input type="hidden" name="prevFlag" value="${prevFlag}"/>
	<input type="hidden" name="next_or_prev" value="-"/>
	<input type="hidden" name="PJT_NAME" value="-">
	<input type="hidden" name="TOT_GVRN_CNBN" value="-">
	<input type="hidden" name="PART_INST_NAME" value="-">
	<input type="hidden" name="VOUCH_NEEDS" value="-">
	<input type="hidden" name="TECH_NEEDS" value="-">
	<input type="hidden" name="TECH_DESC" value="-">
	<input type="hidden" name="TECH_PLAN" value="-">
	<input type="hidden" name="REQ_ITEMS" value="-">
	<input type="hidden" name="ATTACH_FILE_ID" value="-">
	<input type="hidden" name="INFO_AGREE_YN" value="-">
	<input type="hidden" name="USER_ID" value="-">
	<input type="hidden" name="DOC_STEP" value="02">
	<input type="hidden" name="BIZ_REG_NO" value="-"/>
	<input type="hidden" name="APP_NO" value="${APP_NO}">
</form>

<form name="fileDownloadForm" accept-charset="UTF-8">
	<input type="hidden" name="downFile" value="-"/>
	<input type="hidden" name="orgFileName" value="-"/>
</form>

<%@include file="/WEB-INF/jsp/common/include/BodyFooter.jspf" %>

</body>
</html>
