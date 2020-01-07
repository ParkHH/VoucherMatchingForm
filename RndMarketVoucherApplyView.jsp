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
	var overlapCheckFlag = false;
	
	$(function(){
		$("input[name='bt_next']").click(function(){
			next();
		});
		$("input[name='bt_overlap_check']").click(function(){
			businessNumberOverlapCheck();
		});
		$("input[name='bt_search_post_number']").click(function(){
			searchPostNumber();
		});
	});

	
	
	//---------------------------------------------------------------------------
	// 다음버튼
	//---------------------------------------------------------------------------
	function next(){
		$("input[name='next_or_prev']").val("next");																		// 페이지 이동 동작상태를 next 로
		
		//-------------------------------------------------------
		// >> 필수항목
		//-------------------------------------------------------
		var ENTP_NAME = $("input[name='input_corporation_name']").val();										// 기업, 기관명 *
		var BIZ_REG_NO_FRONT = $("input[name='input_business_no_front']").val();							// 사업자번호(앞) *
		var BIZ_REG_NO_MID = $("input[name='input_business_no_mid']").val();								// 사업자번호(중간) *
		var BIZ_REG_NO_REAR = $("input[name='input_business_no_rear']").val();								// 사업자번호(끝) *
		var CEO_NAME = $("input[name='input_representation_name']").val();									// 대표자 이름 *
		var POST_NO = $("input[name='input_post_number']").val();												// 우편번호 *
		var BASE_ADDR = $("input[name='input_address_basic']").val();											// 기본주소 *
		var DTL_ADDR = $("input[name='input_address_detail']").val();												// 상세주소 *
		var CHRG_NAME = $("input[name='input_officer_name']").val();											// 책입자 이름 *
		var CHRG_SN = $("input[name='input_personal_number_front']").val();									// 주민번호 앞자리 *
		var CHRG_DEPT = $("input[name='input_department']").val();												// 부서 *
		var CHRG_DUTY = $("input[name='input_position']").val();													// 직책 *
		var CHRG_CELL_PHONE = $("input[name='input_officer_phone_num']").val();							// 책임자 휴대전화 *
		var CHRG_TEL_NO = $("input[name='input_corperation_contact_num']").val();						// 회사연락처 *
		var CHRG_MAIL_ADDR = $("input[name='input_officer_mail']").val();										// 책임자 메일주소 *
		
		//-------------------------------------------------------
		// >> 비필수항목
		//-------------------------------------------------------
		var COR_NO_FRONT = $("input[name='input_corporation_no_front']").val();				 			// 법인등록번호(앞) 
		var COR_NO_REAR = $("input[name='input_corporation_no_rear']").val();								// 법인등록번호(뒤) 
		var COR_PHONE = $("input[name='input_representation_contact']").val();
		var ENTP_DATE = $("input[name='input_establish_date']").val();
		var ENTP_INDUTY = $("input[name='input_job_kind']").val();
		var EMP_CNT = $("input[name='input_employ_num']").val();
		var SALES_PRICE = $("input[name='input_sales_price']").val();
		var MAIN_PRODUCT = $("textarea[name='input_main_product_service']").val();
		
		//-------------------------------------------------------
		// >> 필수항목 미입력 체크
		//-------------------------------------------------------
		var elements = new Array();
		elements[0]=ENTP_NAME;
		elements[1]=BIZ_REG_NO_FRONT;
		elements[2]=BIZ_REG_NO_MID;
		elements[3]=BIZ_REG_NO_REAR;
		//elements[4]=corporation_no_front;
		//elements[5]=corporation_no_rear;
		elements[4]=CEO_NAME;
		elements[5]=POST_NO;
		elements[6]=BASE_ADDR;
		elements[7]=DTL_ADDR;
		elements[8]=CHRG_NAME;
		elements[9]=CHRG_SN;
		elements[10]=CHRG_DEPT;
		elements[11]=CHRG_DUTY;
		elements[12]=CHRG_CELL_PHONE;
		elements[13]=CHRG_TEL_NO;
		elements[14]=CHRG_MAIL_ADDR;
		
		for(var i=0; i<elements.length; i++){
			var element = elements[i];
			
			if(element == ""){
				alert("필수 입력 항목의 입력 내용을 확인하세요!");
				return;
			}
		}
		
		//-------------------------------------------------------
		// 사업자번호 중복 체크 여부
		//-------------------------------------------------------
		if(!overlapCheckFlag){
			alert("사업자 등록 번호 중복체크를 하지 않았습니다.");
			return;
		}
		
		//-------------------------------------------------------
		// 저장할 내용을 hidden tag 에 담아 form 으로 전송
		//-------------------------------------------------------
		$("input[name='ENTP_NAME']").val(ENTP_NAME);
		$("input[name='BIZ_REG_NO_FRONT']").val(BIZ_REG_NO_FRONT);
		$("input[name='BIZ_REG_NO_MID']").val(BIZ_REG_NO_MID);
		$("input[name='BIZ_REG_NO_REAR']").val(BIZ_REG_NO_REAR)
		$("input[name='BIZ_REG_NO']").val(BIZ_REG_NO_FRONT+'-'+BIZ_REG_NO_MID+'-'+BIZ_REG_NO_REAR);		// 사업자번호 전체
		$("input[name='COR_NO_FRONT']").val(COR_NO_FRONT);
		$("input[name='COR_NO_REAR']").val(COR_NO_REAR);
		$("input[name='COR_NO']").val(COR_NO_FRONT+'-'+COR_NO_REAR);						// 법인등록번호 전체
		$("input[name='CEO_NAME']").val(CEO_NAME);
		$("input[name='COR_PHONE']").val(COR_PHONE);
		$("input[name='POST_NO']").val(POST_NO);
		$("input[name='BASE_ADDR']").val(BASE_ADDR);
		$("input[name='DTL_ADDR']").val(DTL_ADDR);
		$("input[name='ENTP_DATE']").val(ENTP_DATE);
		$("input[name='ENTP_INDUTY']").val(ENTP_INDUTY);
		$("input[name='EMP_CNT']").val(EMP_CNT);
		$("input[name='SALES_PRICE']").val(SALES_PRICE);
		$("input[name='MAIN_PRODUCT']").val(MAIN_PRODUCT);
		$("input[name='CHRG_NAME']").val(CHRG_NAME);
		$("input[name='CHRG_SN']").val(CHRG_SN);
		$("input[name='CHRG_DEPT']").val(CHRG_DEPT);
		$("input[name='CHRG_DUTY']").val(CHRG_DUTY);
		$("input[name='CHRG_CELL_PHONE']").val(CHRG_CELL_PHONE);
		$("input[name='CHRG_TEL_NO']").val(CHRG_TEL_NO);
		$("input[name='CHRG_MAIL_ADDR']").val(CHRG_MAIL_ADDR);
		$("input[name='USER_ID']").val($("input[name='loginId']").val());
		
		$("#voucherApplyForm").attr({
			action:"/rndmarket/voucher/getApplyView2.do",
		 	method:"post"
		});
		$("#voucherApplyForm").submit();
	}
	
	
	//---------------------------------------------------------------------------
	// 사업자 등록번호 중복체크 버튼
	//---------------------------------------------------------------------------
	function businessNumberOverlapCheck(){
		var BIZ_REG_NO_FRONT = $("input[name='input_business_no_front']").val();								// 사업자번호(앞) *
		var BIZ_REG_NO_MID = $("input[name='input_business_no_mid']").val();									// 사업자번호(중간) *
		var BIZ_REG_NO_REAR = $("input[name='input_business_no_rear']").val();								// 사업자번호(끝) *
		var BIZ_REG_NO = BIZ_REG_NO_FRONT+'-'+BIZ_REG_NO_MID+'-'+BIZ_REG_NO_REAR;				// 사업자번호
		
		overlapCheckFlag = false;
		
		if(BIZ_REG_NO=="--"){
			alert("사업자 등록 번호를 입력하세요.");
			return;
		}else if(BIZ_REG_NO_FRONT.length != 3){
			alert("사업자 등록번호 첫번째 자리는 세자리입니다.");
			return;
		}else if(BIZ_REG_NO_MID.length != 2){
			alert("사업자 등록번호 두번째 자리는 두자리입니다.");
			return;
		}else if(BIZ_REG_NO_REAR.length != 5){
			alert("사업자 등록번호 세번째 자리는 다섯자리입니다.");
			return;
		}
		
		$.ajax({
			url:"/rndmarket/voucher/overlapCheck.do",
			type:"get",
			data:{
				BIZ_REG_NO : BIZ_REG_NO
			},
			success:function(result){
				var json = JSON.parse(result);
				var resultCode = json.resultCode;
				if(resultCode>0){
					alert("기존 매칭신청내역이 존재합니다.\n매칭신청현황을 확인하시기 바랍니다.\n(기업당 매칭신청은 1건만 가능합니다.)");
					location.href="/rndmarket/voucher/getSearchView.do";
				}else{
					alert("사용할 수 있는 사업자번호입니다.");	
					overlapCheckFlag = true;
				}
			}
		});
	}
	
	
	//---------------------------------------------------------------------------
	// 우편번호 찾기 버튼
	//---------------------------------------------------------------------------
	function searchPostNumber(){
		//alert("search PostNumber Clicked!!");
		fnAddrPopup();
	}
	
	
	//---------------------------------------------------------------------------
	//우편번호, 주소 검색
	//---------------------------------------------------------------------------
	function fnAddrPopup(){
	    var width = 570;
	    var height = 420;
	    var left = (screen.width-width)/2;
	    var top=(screen.height-height)/2;

	    window.open("<c:url value="/expert/outer/getAddrView.do" />", 'pop', 'width='+width+', height='+height+', top='+top+', left='+left+', toolbar=no, menubar=no, scrollbars=no, resizable=no, copyhistory=no');
	}

	
	//---------------------------------------------------------------------------
	//우편번호, 주소 검색 Popup 창에서 선택값 리턴
	//---------------------------------------------------------------------------
	function jusoCallBack(roadFullAddr, roadAddrPart1, addrDetail, roadAddrPart2, engAddr, jibunAddr, zipNo, admCd, rnMgtSn, bdMgtSn){
	    $("input[name='input_post_number']").val(zipNo);
	    $("input[name='input_address_basic']").val(roadAddrPart1);
	    $("input[name='input_address_detail']").val(addrDetail);
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
		
        <div id="subCon" style="width:100%;">
            <c:out value="${viewContentsHeader}" escapeXml="false" />
			
			<div id="bannerDiv_front" style="width:100%; height:90px; margin-bottom:10px;">
				<img src="/images/voucher_matching/images/vm_appl_step01.gif" style="width:90%; height:100%;"/>
			</div>
			<div id="buttonDiv" style="width:100%; height:30%; text-align:right; margin-bottom:10px;">
				<input type="button" name="bt_next"  class="btn btnBasic" style="width:8%; height:30px; font-size:25px;" value="다음"/>
			</div>
			<div id="infoDiv" style="width:100%; height:25px; padding-top:10px; border-top:1px solid dodgerblue; border-bottom:1px solid dodgerblue;">
				<span style="color:dodgerblue">
					<b>* 붉은색 별표는 필수 입력 사항입니다.</b><br>
				</span>
			</div>
			
			<div class="subSection" style="margin-bottom:10px; height:25px; line-height:25px; !important;">
				<span>기업정보</span>
            </div>
            
            <table class="basicCon conboxTop" style="width:100%">
            	<tr>
            		<th scope="row" style="width:15%;"><b>기업/기관명</b><b style="color:red;"> *</b></th>
            		<td colspan='3' style="padding-left:10px;">
            			<input type="text" name="input_corporation_name" style="width:98%;" value="${voucherJSON.ENTP_NAME}"/>
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:15%;"><b>사업자번호</b><b style="color:red;"> *</b></th>
            		<td style="padding-left:10px;">
            			<input type="text" name="input_business_no_front" style="width:13%;" value="${voucherJSON.BIZ_REG_NO_FRONT}" maxlength=3/> <b>-</b>
            			<input type="text" name="input_business_no_mid" style="width:8%;" value="${voucherJSON.BIZ_REG_NO_MID}" maxlength=2/> <b>-</b>
            			<input type="text" name="input_business_no_rear" style="width:25%;" value="${voucherJSON.BIZ_REG_NO_REAR}" maxlength=5/>
            			<input type="button" name="bt_overlap_check" style="width:80px; height:25px; background:black; color:white;" value="+ 중복체크"/>
            		</td>
            		<th scope="row" style="width:15%;"><b>법인등록번호</b></th>
            		<td style="padding-left:10px;">
            			<input type="text" name="input_corporation_no_front" style="width:40%;" value="${voucherJSON.COR_NO_FRONT}"/> <b>-</b>
            			<input type="text" name="input_corporation_no_rear" style="width:40%;" value="${voucherJSON.COR_NO_REAR}"/>
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:15%;"><b>대표자이름</b><b style="color:red;"> *</b></th>
            		<td style="padding-left:10px;">
            			<input type="text" name="input_representation_name" style="width:95%;" value="${voucherJSON.CEO_NAME}"/>
            		</td>
            		<th scope="row" style="width:15%;"><b>대표 연락처</b></th>
            		<td style="padding-left:10px;">
            			<input type="text" name="input_representation_contact" style="width:95%;" value="${voucherJSON.COR_PHONE}"/>
            		</td>
            	</tr>
            	<tr>            		
            		<th scope="row" style="width:15%;"><b>주소</b><b style="color:red;"> *</b></th>            		
            		<td colspan='3'>
            			<table style="width:100%;">
            				<tr>
            					<td style="width:10%;"><b>우편번호</b></td>
            					<td style="padding-left:10px;">
            						<input type="text" name="input_post_number" style="width:100px;" value="${voucherJSON.POST_NO}"/>
            						<input type="button" class="btn btnSearch" name="bt_search_post_number"/>
            					</td>
            				</tr>
            				<tr>
            					<td style="width:10%;"><b>기본주소</b></td>
            					<td style="padding-left:10px;">
            						<input type="text" name="input_address_basic" style="width:98%;" value="${voucherJSON.BASE_ADDR}"/>
            					</td>
            				</tr>
            				<tr>
            					<td style="width:10%;"><b>상세주소</b></td>
            					<td style="padding-left:10px;">
            						<input type="text" name="input_address_detail" style="width:98%;" value="${voucherJSON.DTL_ADDR}"/>
            					</td>
            				</tr>
            			</table>
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:15%;"><b>설립일</b></th>
            		<td style="padding-left:10px;">
            			<input type="text" name="input_establish_date" style="width:95%;" placeholder="20200101" value="${voucherJSON.ENTP_DATE}"/>
            		</td>
            		<th scope="row" style="width:15%;"><b>업종</b></th>
            		<td style="padding-left:10px;">
            			<input type="text" name="input_job_kind" style="width:95%;" value="${voucherJSON.ENTP_INDUTY}"/>
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:15%;"><b>상시종업원수(명)</b></th>
            		<td style="padding-left:10px;">
            			<input type="text" name="input_employ_num" style="width:95%;" value="${voucherJSON.EMP_CNT}"/>
            		</td>
            		<th scope="row" style="width:15%;"><b>* 19년 매출액(억원)</b></th>
            		<td style="padding-left:10px;">
            			<input type="text" name="input_sales_price" style="width:95%;" value="${voucherJSON.SALES_PRICE}"/>
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:15%;"><b>주요제품/서비스 <br>(300자 이내)</b></th>
            		<td colspan='3'>
            			<textarea rows="4" cols="10" name="input_main_product_service" maxlength="300">${voucherJSON.MAIN_PRODUCT}</textarea>
            		</td>
            	</tr>
            </table>
            
            <br><br>
            
            <div class="subSection" style="margin-bottom:10px; height:25px; line-height:25px; !important;">
				<span>책임자 정보</span>
            </div>
            
            <table class="basicCon conboxTop" style="width:100%">
            	<tr>
            		<th scope="row" style="width:15%;"><b>책임자 이름</b><b style="color:red;"> *</b></th>
            		<td style="padding-left:10px;">
            			<input type="text" name="input_officer_name" style="width:95%;" value="${voucherJSON.CHRG_NAME}"/>
            		</td>
            		<th scope="row" style="width:15%;"><b>주민번호 앞자리</b><b style="color:red;"> *</b></th>
            		<td style="padding-left:10px;">
            			<input type="text" name="input_personal_number_front" style="width:95%;" value="${voucherJSON.CHRG_SN}"/>
            		</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:15%;"><b>부서</b><b style="color:red;"> *</b></th>
            		<td style="padding-left:10px;">
            			<input type="text" name="input_department" style="width:95%;" value="${voucherJSON.CHRG_DEPT}"/>
            		</td>
            		<th scope="row" style="width:15%;"><b>직책</b><b style="color:red;"> *</b></th>
            		<td style="padding-left:10px;">
            			<input type="text" name="input_position" style="width:95%;" value="${voucherJSON.CHRG_DUTY }"/>
            		</td>
            	</tr>
            	<tr>
	            	<th scope="row" style="width:15%;"><b>책임자 휴대전화</b><b style="color:red;"> *</b></th>
	            	<td style="padding-left:10px;">
	            		<input type="text" name="input_officer_phone_num" style="width:95%;" value="${voucherJSON.CHRG_CELL_PHONE }"/>
	            	</td>
	            	<th scope="row" style="width:15%;"><b>회사 연락처</b><b style="color:red;"> *</b></th>
	            	<td style="padding-left:10px;">
	            		<input type="text" name="input_corperation_contact_num" style="width:95%;" value="${voucherJSON.CHRG_TEL_NO }"/>
	            	</td>
            	</tr>
            	<tr>
            		<th scope="row" style="width:15%;"><b>책임자 메일주소</b><b style="color:red"> *</b></th>
            		<td colspan='3' style="padding-left:10px;">
            			<input type="text" name="input_officer_mail" style="width:98%;" value="${voucherJSON.CHRG_MAIL_ADDR }"/>
            		</td>
            	</tr>
            </table>
                                   
            <div id="buttonDiv_rear" style="width:100%; height:30%; text-align:right; margin-top:20px;">
				<input type="button" name="bt_next"  class="btn btnBasic" style="width:8%; height:30px; font-size:25px;" value="다음"/>
			</div>
    </div> 
</div>

<c:out value="${viewLayoutBottom}" escapeXml="false" />
</form>

<form id="voucherApplyForm">
	<input type="hidden" name="prevFlag" value="${prevFlag}"/>
	<input type="hidden" name="next_or_prev" value="-"/>
   	<input type="hidden" name="ENTP_NAME" value="-"/>
   	<input type="hidden" name="BIZ_REG_NO_FRONT" value="-"/>
   	<input type="hidden" name="BIZ_REG_NO_MID" value="-"/>
   	<input type="hidden" name="BIZ_REG_NO_REAR" value="-"/>
   	<input type="hidden" name="BIZ_REG_NO" value="-"/>
   	<input type="hidden" name="COR_NO_FRONT" value="-"/>
   	<input type="hidden" name="COR_NO_REAR" value="-"/>
   	<input type="hidden" name="COR_NO" value="-"/>
   	<input type="hidden" name="CEO_NAME" value="-"/>
   	<input type="hidden" name="COR_PHONE" value="-"/>
   	<input type="hidden" name="POST_NO" value="-"/>
   	<input type="hidden" name="BASE_ADDR" value="-"/>
   	<input type="hidden" name="DTL_ADDR" value="-"/>
   	<input type="hidden" name="ENTP_DATE" value="-"/>
   	<input type="hidden" name="ENTP_INDUTY" value="-"/>
   	<input type="hidden" name="EMP_CNT" value="0"/>
   	<input type="hidden" name="SALES_PRICE" value="0"/>
   	<input type="hidden" name="MAIN_PRODUCT" value="-"/>
   	<input type="hidden" name="CHRG_NAME" value="-"/>
   	<input type="hidden" name="CHRG_SN" value="0"/>
   	<input type="hidden" name="CHRG_DEPT" value="-"/>
   	<input type="hidden" name="CHRG_DUTY" value="-"/>
   	<input type="hidden" name="CHRG_CELL_PHONE" value="-"/>
   	<input type="hidden" name="CHRG_TEL_NO" value="-"/>
   	<input type="hidden" name="CHRG_MAIL_ADDR" value="-"/>
   	<input type="hidden" name="DOC_STEP" value="01">
   	<input type="hidden" name="DOC_STATUS" value="${DOC_STATUS}">
   	<input type="hidden" name="APP_NO" value="${APP_NO}">
   	<input type="hidden" name="USER_ID" value="-">
</form>

<%@include file="/WEB-INF/jsp/common/include/BodyFooter.jspf" %>

</body>
</html>
