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
		$("input[name='bt_save']").click(function(){
			save();
		});
		$("input[name='bt_submit']").click(function(){
			submit();
		});
	});
	
	
	// 이전 버튼
	function goPrevPage(){
		$("input[name='next_or_prev']").val("prev");
		var docStatus = $("input[name='DOC_STATUS']").val();
		var goPageURL = "";
		if(docStatus != '03'){
			goPageURL="/rndmarket/voucher/getApplyView2.do";
		}else{
			goPageURL="/rndmarket/voucher/getSearchView.do";
		}
		
		$("form[name='voucherApplyForm3']").attr({
			action:goPageURL,
			method:"post"
		});
		$("form[name='voucherApplyForm3']").submit();
	}
	
	
	
	// 저장 버튼
	function save(){
		var charCount = 0;
		var password = $("input[name='input_password']").val();			// 비밀번호
		var APP_NO = $("input[name='APP_NO']").val();						// 신청일련번호
		var DOC_STEP = $("input[name='DOC_STEP']").val();
		if(password.length<6){
			if(password.length == 0){
				alert("비밀번호는 필수 입력 사항입니다");
			}else{
				alert("비밀번호는 영어, 숫자 조합으로 6자리 이상으로 설정해야합니다.");
			}
			return;
		}else{
			for(var i=0; i<password.length; i++){
				if(!isNaN(password[i])){
					continue;
				}else{
					charCount++;
				}
			}
			
			if(charCount == 0){
				alert("비밀번호는 영어, 숫자 조합으로 6자리 이상으로 설정해야합니다.");
				return;
			}else{
				$.ajax({
					url:"/rndmarket/voucher/savePassword.do",
					type:"post",
					data:{
						DOC_PASS : password,
						DOC_STEP : DOC_STEP,
						APP_NO : APP_NO
					},
					success:function(result){
						//alert(result);
						var json = JSON.parse(result);
						var resultCode = json.result;
						if(resultCode > 0){
							alert("매칭지원 신청이 작성완료 되었습니다.\n신청번호는 "+APP_NO+" 입니다.");
						}else{
							alert("암호 등록 실패!");
						}
					}
				});
			}
		}
	}
	
	
	// 제출 버튼
	function submit(){
		if(!confirm("최종 제출 이후에는 수정이 불가능합니다.\n제출하시겠습니까?")){
			return;
		}
		
		var checkState = checkAgreeState();
		if(!checkState){
			return;
		}
		
		var APP_NO = $("input[name='APP_NO']").val();					// 신청일련번호
		var ENTP_NAME = $("input[name='ENTP_NAME']").val();		// 기업명
		var CHRG_NAME = $("input[name='CHRG_NAME']").val();			// 책임자명
		var TECH_NEEDS = $("input[name='TECH_NEEDS']").val();			// 기술명
		
		
		$.ajax({
			url:"/rndmarket/voucher/VoucherMatchingSubmit.do",
			type:"post",
			data:{
				APP_NO : APP_NO,
				ENTP_NAME : ENTP_NAME,
				CHRG_NAME : CHRG_NAME,
				TECH_NEEDS : TECH_NEEDS
			},
			success:function(result){
				var json = JSON.parse(result);
				var resultCode = json.result;
				if(resultCode > 0){
					alert("제출 완료!");
					window.location.reload();
				}else{
					alert("제출이 이미 완료된 신청건입니다!");
				}
			}
		});
	}
	
	
	
	// 동의 여부 체크
	function checkAgreeState(){
		var checkState = $("input[name='ckb_agree']").is(":checked");
		if(!checkState){
			alert("동의 여부 상태를 확인하세요.");
		}
		
		return checkState;
	}
	
	
	// 파일 다운로드
	function fileDown(){
		var APP_NO = $("input[name='APP_NO']").val();
		location.href = "/rndmarket/voucher/fileDownload.do?APP_NO="+APP_NO;
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

<form name="frm_main">

<input type="hidden" id="RETURN_SUBJECT">
<input type="hidden" id="RETURN_REASON">
<input type="hidden" name="test_APP_NO" value="${APP_NO}"/>


<div id="wrap">
    <c:out value="${viewLayoutTop}" escapeXml="false" />

    <div id="container" class="sub">
        <c:out value="${viewLayoutLeft}" escapeXml="false" />
		
        <div id="subCon" style="width:100%;">
            <c:out value="${viewContentsHeader}" escapeXml="false" />
			
			<div id="bannerDiv_front" style="width:100%; height:90px; margin-bottom:10px;">
				<img src="/images	/voucher_matching/images/vm_appl_step03.gif" style="width:90%; height:100%;"/>
			</div>
			<div id="buttonDiv" style="width:100%; height:30%; text-align:right; margin-bottom:10px;">
				<input type="button" name="bt_prev"  class="btn btnBasic" style="width:8%; height:30px; font-size:25px;" value="이전"/>
				<c:set var="status" value="${voucherJSON.DOC_STATUS}"/>
				<c:if test="${status eq '01' || status eq '02'}">
					<input type="button" name="bt_save"  class="btn btnBasic" style="width:8%; height:30px; font-size:25px;" value="저장"/>
					<input type="button" name="bt_submit"  class="btn btnBasic" style="width:8%; height:30px; font-size:25px;" value="제출"/>
				</c:if>
			</div>
			<div id="infoDiv" style="width:100%; height:110px; padding-top:10px; border-top:1px solid dodgerblue; border-bottom:1px solid dodgerblue;">
				<span style="color:dodgerblue"><b>* 저장 이후 사업자 등록번호, 매칭신청번호, 비밀번호는 신청내역 조회시 필요합니다.</b></span><br><br>
				<span style="color:dodgerblue"><b>* 최종 제출 전까지는 신청현황 조회 후 수정 및 제출이 가능합니다.</b></span><br><br>
				<span style="color:dodgerblue"><b>* 최종 제출 이후에는 수정이 불가능 하오니 확인 후 제출하십시오.</b></span><br><br>
				<span style="color:dodgerblue"><b>* 붉은색 별표는 필수 입력 사항입니다.</b></span><br><br>
			</div>
			
			<div class="subSection" style="margin-bottom:10px; height:25px; line-height:25px; !important;">
				<span>기업정보</span>
            </div>
            
            <table class="basicCon conboxTop" style="width:100%; table-layout:fixed;" >
            	<tr>
            		<th scope="row" style="width:18%;"><b>기업/기관명</b></th>
            		<td style="padding-left:10px;">
            			${voucherJSON.ENTP_NAME}
            		</td>
            		<td style="width:18%;"></td>
            		<td></td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%;"><b>사업자번호</b></th>
            		<td style="padding-left:10px;">
            			${voucherJSON.BIZ_REG_NO_FRONT}<b>-</b>${voucherJSON.BIZ_REG_NO_MID}<b>-</b>${voucherJSON.BIZ_REG_NO_REAR}
            		</td>
            		<th scope="row" style="width:18%;"><b>법인등록번호</b></th>
            		<td style="padding-left:10px;">
            			${voucherJSON.COR_NO_FRONT}<b>-</b>${voucherJSON.COR_NO_REAR}
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%;"><b>대표자이름</b></th>
            		<td style="padding-left:10px;">
            			${voucherJSON.CEO_NAME}
            		</td>
            		<th scope="row" style="width:15%;"><b>대표 연락처</b></th>
            		<td style="padding-left:10px;">
            			${voucherJSON.COR_PHONE}
            		</td>
            	</tr>
            	<tr>            		
            		<th scope="row" style="width:18%;"><b>주소</b></th>            		
            		<td colspan='3'>
            			<table style="width:100%;">
            				<tr>
            					<td style="width:10%;"><b>우편번호</b></td>
            					<td style="padding-left:10px;">
            						${voucherJSON.POST_NO}
            					</td>
            				</tr>
            				<tr>
            					<td style="width:10%;"><b>기본주소</b></td>
            					<td style="padding-left:10px;">
            						${voucherJSON.BASE_ADDR}
            					</td>
            				</tr>
            				<tr>
            					<td style="width:10%;"><b>상세주소</b></td>
            					<td style="padding-left:10px;">
            						${voucherJSON.DTL_ADDR}
            					</td>
            				</tr>
            			</table>
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%;"><b>설립일</b></th>
            		<td style="padding-left:10px;">
            			${voucherJSON.ENTP_DATE}
            		</td>
            		<th scope="row" style="width:15%;"><b>업종</b></th>
            		<td style="padding-left:10px;">
            			${voucherJSON.ENTP_INDUTY}
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%;"><b>상시종업원수(명)</b></th>
            		<td style="padding-left:10px;">
            			${voucherJSON.EMP_CNT}
            		</td>
            		<th scope="row" style="width:15%;"><b>* 19년 매출액(억원)</b></th>
            		<td style="padding-left:10px;">
            			${voucherJSON.SALES_PRICE}
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%;"><b>주요제품/서비스</b></th>
            		<td colspan='3'>
            			${voucherJSON.MAIN_PRODUCT}
            		</td>
            	</tr>
            </table>
            
            <br><br>
            
            <div class="subSection" style="margin-bottom:10px; height:25px; line-height:25px; !important;">
				<span>책임자 정보</span>
            </div>
            
            <table class="basicCon conboxTop" style="width:100%">
            	<tr>
            		<th scope="row" style="width:18%;"><b>책임자 이름</b></th>
            		<td style="padding-left:10px;">
            			${voucherJSON.CHRG_NAME}
            		</td>
            		<th scope="row" style="width:18%;"><b>주민번호 앞자리</b></th>
            		<td style="padding-left:10px;">
            			${voucherJSON.CHRG_SN}
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%;"><b>부서</b></th>
            		<td style="padding-left:10px;">
            			${voucherJSON.CHRG_DEPT}
            		</td>
            		<th scope="row" style="width:18%;"><b>직책</b></th>
            		<td style="padding-left:10px;">
            			${voucherJSON.CHRG_DUTY }
            		</td>
            	</tr>
            	<tr>
	            	<th scope="row" style="width:18%;"><b>책임자 휴대전화</b></th>
	            	<td style="padding-left:10px;">
	            		${voucherJSON.CHRG_CELL_PHONE }
	            	</td>
	            	<th scope="row" style="width:18%;"><b>회사 연락처</b></th>
	            	<td style="padding-left:10px;">
	            		${voucherJSON.CHRG_TEL_NO }
	            	</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%;"><b>책임자 메일주소</b></th>
            		<td colspan='3' style="padding-left:10px;">
            			${voucherJSON.CHRG_MAIL_ADDR }"
            		</td>
            	</tr>
            </table>
			
			<br><br>
			
			<div class="subSection" style="margin-bottom:10px; height:25px; line-height:25px; !important;">
				<span>필요기술정보</span>
            </div>
            
            <table class="basicCon conboxTop" style="width:100%">
            	<tr>
            		<th scope="row" style="width:18%;"><b>과제명</b></th>
            		<td style="padding-left:10px;">
            			${voucherJSON.PJT_NAME}
            		</td>
            		<td style="width:18%;"></td>
            		<td></td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%;"><b>정부출연금(백만원)</b></th>
            		<td style="padding-left:10px;">
            			${voucherJSON.TOT_GVRN_CNBN}
            		</td>
            		<th scope="row" style="width:18%;"><b>참여기관</b></th>
            		<td style="padding-left:10px;">
            			${voucherJSON.PART_INST_NAME}
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%;"><b>바우처지원 필요성</b></th>
            		<td  colspan='3' style="padding-left:10px;">
            			${voucherJSON.VOUCH_NEEDS}
            		</td>           
            	</tr>
            	<tr>            		
            		<th scope="row" style="width:18%;"><b>필요기술명</b></th>            		
            		<td colspan='3' style="padding-left:10px;">
            			${voucherJSON.TECH_NEEDS}
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%;"><b>필요기술의 설명 및 <br>목표 성능치</b></th>
            		<td colspan='3' style="padding-left:10px;">
            			${voucherJSON.TECH_DESC}
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%;"><b>필요기술이 적용될 제품 및<br> 사업화 계획</b></th>
            		<td colspan='3' style="padding-left:10px;">
            			${voucherJSON.TECH_PLAN}
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%;"><b>기타요구사항</b></th>
            		<td colspan='3' style="padding-left:10px;">
            			${voucherJSON.REQ_ITEMS}
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:18%"><b>기술제안서</b></th>
            		<td colspan='3'>
            			<a href="javascript:fileDown()">${voucherJSON.ATTACH_FILE_ID}</a>
            		</td>
            	</tr>
				<c:if test="${status eq '01' || status eq '02'}">
	            	<tr>
	            		<td colspan='4'>
	            			<span><b style="color:red">* </b><b>매칭신청서 내용(필요 기술정보)은 연구자/연구기관 탐색 및 매칭을 위해 공개됨을 동의합니다</b></span>
	            			<input type="checkbox" name="ckb_agree"/><br>
	            			&nbsp;&nbsp;&nbsp;&nbsp;<span><b>(기업정보 및 책임자 정보는 공개되지 않습니다.)</b></span>
	            		</td>
	            	</tr>
            	</c:if>
            </table>
            <br><br><br>
            <c:if test="${status eq '01' || status eq '02'}">
	            <table class="basicCon conboxTop" style="width:100%">
	            	<tr>
	            		<th scope="row" style="width:15%;">비밀번호</th>
	            		<td colspan='3'>
	            			<input type="password" name="input_password"  style="width:100%; height:20px;"/>
	            		</td>
	            	</tr>
	            </table>
            </c:if>
            <div id="buttonDiv_rear" style="width:100%; height:30%; text-align:right; margin-top:20px;">
				<input type="button" name="bt_prev"  class="btn btnBasic" style="width:8%; height:30px; font-size:25px;" value="이전"/>
				<c:if test="${status eq '01' || status eq '02'}">
					<input type="button" name="bt_save"  class="btn btnBasic" style="width:8%; height:30px; font-size:25px;" value="저장"/>
					<input type="button" name="bt_submit"  class="btn btnBasic" style="width:8%; height:30px; font-size:25px;" value="제출"/>
				</c:if>
			</div>
    </div> 
</div>
<c:out value="${viewLayoutBottom}" escapeXml="false" />
</form>

<input type="hidden" name="hidden_saveResult" value="${saveResult}"/>

<form name='voucherApplyForm3'>
	<input type="hidden" name="next_or_prev" value=""/>
	<input type="hidden" name="ENTP_NAME" value="${voucherJSON.ENTP_NAME}"/>
	<input type="hidden" name="CHRG_NAME" value="${voucherJSON.CHRG_NAME}"/>
	<input type="hidden" name="TECH_NEEDS" value="${voucherJSON.TECH_NEEDS}"/>
	<input type="hidden" name="INFO_AGREE_YN" value="-">
	<input type="hidden" name="USER_ID" value="-">
	<input type="hidden" name="DOC_STEP" value="03">
	<input type="hidden" name="DOC_STATUS" value="${voucherJSON.DOC_STATUS}">
	<input type="hidden" name="APP_NO" value="${APP_NO}">
</form>

<form name="fileDownloadForm" accept-charset="UTF-8">
	<input type="hidden" name="downFile" value=""/>
	<input type="hidden" name="orgFileName" value=""/>
</form>

<%@include file="/WEB-INF/jsp/common/include/BodyFooter.jspf" %>

</body>
</html>
