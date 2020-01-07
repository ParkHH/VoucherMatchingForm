package iitp.ictbay.rndmarket.voucher.service;

import iitp.ictbay.common.abstractmvc.CommonAbstractService;
import iitp.ictbay.common.mail.service.CommonMailQueueService;
import iitp.ictbay.common.mail.service.CommonMailVO;
import iitp.ictbay.common.util.CommonUtil;
import iitp.ictbay.common.util.LoginUserVO;
import iitp.ictbay.common.util.RequestData;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.rte.fdl.cmmn.exception.BaseException;
import egovframework.rte.ptl.mvc.tags.ui.pagination.PaginationInfo;

@Service("rndMarketVoucherService")
public class RndMarketVoucherService extends CommonAbstractService{
	 @Resource
	    protected CommonMailQueueService commonMailQueueService;

	    /**
	     *  R&D서비스 승인건 통보 메일 발송 처리
	     *
	     * @param reqData
	     */
	    public void sendMail(Map<String, Object> commandMap) throws BaseException
	    {
	        LoginUserVO loginUser = CommonUtil.getLoginUserVO();
	        String menu = "R&D바우처 > 기술매칭 지원 > 매칭 지원 신청";
	        String recvPersonId =  loginUser.getPersonId();
	        String recvName = loginUser.getKoName();
	        String recvMailAddr = loginUser.getMailAddr();
	        String sendPersonId = "754UA01260000B8000";
	        String sendName = "IITP_정보통신기술진흥센터";
	        String sendMailAddr = "ictbay@iitp.kr";
	        
	        String APP_NO = commandMap.get("APP_NO").toString();
	        String ENTP_NAME = commandMap.get("ENTP_NAME").toString();
	        String CHRG_NAME = commandMap.get("CHRG_NAME").toString();
	        String TECH_NEEDS = commandMap.get("TECH_NEEDS").toString();
	        String REG_DATE = "";
	        
	        SimpleDateFormat format1 = new SimpleDateFormat ( "yyyy-MM-dd HH:mm:ss");
	        Date time = new Date();
	        String time1 = format1.format(time);
	        REG_DATE = time1.substring(0,10);

            CommonMailVO mailVO = new CommonMailVO();
            mailVO.setFrom(sendMailAddr, sendName, sendPersonId);
            mailVO.addTo("phh_92@naver.com", "박현호", "phh_92");
            mailVO.setMailInfo("REF_ID", commandMap.get("APP_NO").toString());
            mailVO.setMailInfo("BODY_HEAD", "ICT R&D 바우처 매칭 신청이 접수 되었습니다");
            mailVO.setMailInfo("BODY_TASK", ENTP_NAME + " 의 " + mailVO.getMailInfo("BODY_HEAD")+"<br>귀하께서 신청하신 바우처 매칭신청 결과가 아래와 같이 정상 제출 되었습니다.<br><br>-매칭신청번호 : "+APP_NO+"<br>-기업명 : "+ENTP_NAME+"<br>-기술명 : "+TECH_NEEDS+"<br>-신청일 : "+REG_DATE+"<br><br>비밀번호 분실시 메일이나 전화로 연락 바랍니다.");
            mailVO.setMailInfo("BODY_MENU", menu);
            mailVO.setSubject(mailVO.getMailInfo("BODY_TASK"));
            mailVO.setMailInfo("ENTP_NAME", ENTP_NAME);
            commonMailQueueService.create(mailVO);
	    }
	    
	    
	    // 사업자 등록번호 중복체크
	    public String businessNumOverlapCheck(String BIZ_REG_NO){
	    	int businessNumOverlapCount = mapper.query("rndmarket.voucher.RndMarketVoucherMapper.selectBusinessNum").bind("BIZ_REG_NO", BIZ_REG_NO).selectOne();
	    	
	    	StringBuilder sb = new StringBuilder();
	    	sb.append("{");
	    	sb.append("\"resultCode\" : \""+businessNumOverlapCount+"\"");
	    	sb.append("}");
	    	
	    	return sb.toString();
	    }
	    
	    
	    
	    
	    
	    
	    
	    
	    //------------------------------------------------------------------------------------------------------------------------
	    // 바우처 마지막 일련번호 가져와서 새로운 일련번호 끝자리 구하기
	    //------------------------------------------------------------------------------------------------------------------------
	    public int getNextVoucherNum(){
	    	String lastVoucherNum = mapper.query("rndmarket.voucher.RndMarketVoucherMapper.selectLastVoucherNum").selectOne();
	    	String nextVoucherNum = "";
	    	int integerNextVoucherNum = 0;
	    	String[] lastVoucherNumSplit = lastVoucherNum.split("-");
	    	String rearVoucherNum = lastVoucherNumSplit[lastVoucherNumSplit.length-1];
	    	char[] rearVoucherNumCharArr = rearVoucherNum.toCharArray();
	    	int position = 0;
	    	
	    	for(int i=0; i<rearVoucherNum.length(); i++){
	    		char num = rearVoucherNumCharArr[i];
	    		if(rearVoucherNum.length() > 1){
	    			if(position == 0){
		    			if(num != '0'){
			    			nextVoucherNum+=num;
			    			position = i;
			    		}
	    			}else{
	    				nextVoucherNum+=num;
	    			}
	    		}else{
	    			nextVoucherNum+=num;
	    		}
	    		
	    	}
	    	
	    	integerNextVoucherNum = Integer.parseInt(nextVoucherNum)+1;
	    	
	    	return integerNextVoucherNum;
	    }
	    
	    
	    //------------------------------------------------------------------------------------------------------------------------
	    // step1 입력 정보 저장
	    //------------------------------------------------------------------------------------------------------------------------
	    public int InsertOrUpdateStep1Info(Map<String, Object> commandMap){
	    	int result = 0;
	    	
    		//---------------------------------------------------------------
    		// 필수항목
    		//---------------------------------------------------------------
	    	String APP_NO = commandMap.get("APP_NO").toString();
	    	String ENTP_NAME = commandMap.get("ENTP_NAME").toString();
	    	String BIZ_REG_NO_FROT = commandMap.get("BIZ_REG_NO_FRONT").toString();
	    	String BIZ_REG_NO_MID = commandMap.get("BIZ_REG_NO_MID").toString();
	    	String BIZ_REG_NO_REAR = commandMap.get("BIZ_REG_NO_REAR").toString();
	    	String BIZ_REG_NO = commandMap.get("BIZ_REG_NO").toString();
	    	String CEO_NAME = commandMap.get("CEO_NAME").toString();
	    	String POST_NO = commandMap.get("POST_NO").toString();
	    	String BASE_ADDR = commandMap.get("BASE_ADDR").toString();
	    	String DTL_ADDR = commandMap.get("DTL_ADDR").toString();
	    	String CHRG_NAME = commandMap.get("CHRG_NAME").toString();
	    	String CHRG_SN = commandMap.get("CHRG_SN").toString();
	    	String CHRG_DEPT = commandMap.get("CHRG_DEPT").toString();
	    	String CHRG_DUTY = commandMap.get("CHRG_DUTY").toString();
	    	String CHRG_CELL_PHONE = commandMap.get("CHRG_CELL_PHONE").toString();
	    	String CHRG_TEL_NO = commandMap.get("CHRG_TEL_NO").toString();
	    	String CHRG_MAIL_ADDR = commandMap.get("CHRG_MAIL_ADDR").toString();
	    	
	    	//---------------------------------------------------------------
    		// 비필수항목
    		//---------------------------------------------------------------
	    	Object obj_COR_NO_FROT = commandMap.get("COR_NO_FRONT");
	    	Object obj_COR_NO_REAR = commandMap.get("COR_NO_REAR");
	    	Object obj_COR_NO = commandMap.get("COR_NO");
	    	Object obj_COR_PHONE = commandMap.get("COR_PHONE");
	    	Object obj_ENTP_DATE = commandMap.get("ENTP_DATE");
	    	Object obj_ENTP_INDUTY = commandMap.get("ENTP_INDUTY");
	    	Object obj_EMP_CNT = commandMap.get("EMP_CNT");
	    	Object obj_SALES_PRICE = commandMap.get("SALES_PRICE");
	    	Object obj_MAIN_PRODUCT = commandMap.get("MAIN_PRODUCT");
	    	
	    	String COR_NO_FRONT = "-";
	    	String COR_NO_REAR = "-";
	    	String COR_NO = "-";
	    	String COR_PHONE = "-";
	    	String ENTP_DATE = "-";
	    	String ENTP_INDUTY = "-";
	    	int EMP_CNT = 0;
	    	int SALES_PRICE = 0;
	    	String MAIN_PRODUCT = "-";
	    	
	    	if(!obj_COR_NO_FROT.equals("")){
	    		COR_NO_FRONT = obj_COR_NO_FROT.toString();
	    	}
	    	if(!obj_COR_NO_REAR.equals("")){
	    		COR_NO_REAR = obj_COR_NO_REAR.toString();
	    	}
	    	if(!obj_COR_NO.equals("")){
	    		COR_NO = obj_COR_NO.toString();
	    	}
	    	if(!obj_COR_PHONE.equals("")){
	    		COR_PHONE = obj_COR_PHONE.toString();
	    	}
	    	if(!obj_ENTP_DATE.equals("")){
	    		ENTP_DATE = obj_ENTP_DATE.toString();
	    	}
	    	if(!obj_ENTP_INDUTY.equals("")){
	    		ENTP_INDUTY = obj_ENTP_INDUTY.toString();
	    	}
	    	if(!obj_EMP_CNT.equals("")){
	    		EMP_CNT = Integer.parseInt(obj_EMP_CNT.toString());
	    	}
	    	if(!obj_SALES_PRICE.equals("")){
	    		SALES_PRICE = Integer.parseInt(obj_SALES_PRICE.toString());
	    	}
	    	if(!obj_MAIN_PRODUCT.equals("")){
	    		MAIN_PRODUCT = obj_MAIN_PRODUCT.toString();
	    	}
	    	
	    	String DOC_STEP = commandMap.get("DOC_STEP").toString();
	    	String CRE_USER = commandMap.get("USER_ID").toString();
	    	
	    	/*
	    	// DATE 형 COLUMN 이 존재하므로 문자형 데이터를 DATE 형으로 변환
	    	SimpleDateFormat dateFormat = new SimpleDateFormat("yyyymmdd");
	    	SimpleDateFormat dateFormat2 = new SimpleDateFormat("yyyy-mm-dd");
	    	java.sql.Date new_ENTP_DATE = null;
	    	try {
 	    		Date temp_ENTP_DATE = dateFormat.parse(ENTP_DATE);
 	    		String temp2_ENTP_DATE = dateFormat2.format(temp_ENTP_DATE);
 	    		new_ENTP_DATE = java.sql.Date.valueOf(temp2_ENTP_DATE);
				
			} catch (ParseException e) {
				e.printStackTrace();
			}
			*/
	    	
	    	int regCount = mapper.query("rndmarket.voucher.RndMarketVoucherMapper.selectBusinessNumWhile").bind("APP_NO", APP_NO).selectOne();
	    	
	    	
	    	if(regCount==0){
	    		System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 신규작성건이에요!!! INSERT 합니다!!");
	    		result = mapper.query("rndmarket.voucher.RndMarketVoucherMapper.insertStep1").bind("APP_NO", APP_NO)
	    																												   .bind("ENTP_NAME", ENTP_NAME)
																														   .bind("BIZ_REG_NO", BIZ_REG_NO)
																														   .bind("COR_NO", COR_NO)
																														   .bind("CEO_NAME", CEO_NAME)
																														   .bind("COR_PHONE", COR_PHONE)
																														   .bind("POST_NO", POST_NO)
																														   .bind("BASE_ADDR", BASE_ADDR)
																														   .bind("DTL_ADDR",DTL_ADDR)
																														   .bind("ENTP_DATE", ENTP_DATE)
																														   .bind("ENTP_INDUTY", ENTP_INDUTY)
																														   .bind("EMP_CNT", EMP_CNT)
																														   .bind("SALES_PRICE", SALES_PRICE)
																														   .bind("MAIN_PRODUCT", MAIN_PRODUCT)
																														   .bind("CHRG_NAME", CHRG_NAME)
																														   .bind("CHRG_SN", CHRG_SN)
																														   .bind("CHRG_DEPT", CHRG_DEPT)
																														   .bind("CHRG_DUTY", CHRG_DUTY)
																														   .bind("CHRG_CELL_PHONE", CHRG_CELL_PHONE)
																														   .bind("CHRG_TEL_NO", CHRG_TEL_NO)
																														   .bind("CHRG_MAIL_ADDR", CHRG_MAIL_ADDR)
																														   .bind("DOC_STEP", DOC_STEP)
																														   .bind("CRE_USER", CRE_USER)
																														   .insert();
	    	}else{
	    		System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 기작성건이에요!!! Update 합니다!!");
	    		result = mapper.query("rndmarket.voucher.RndMarketVoucherMapper.updateStep1").bind("APP_NO", APP_NO)
	    																													.bind("ENTP_NAME", ENTP_NAME)
																														   .bind("BIZ_REG_NO", BIZ_REG_NO)
																														   .bind("COR_NO", COR_NO)
																														   .bind("CEO_NAME", CEO_NAME)
																														   .bind("COR_PHONE", COR_PHONE)
																														   .bind("POST_NO", POST_NO)
																														   .bind("BASE_ADDR", BASE_ADDR)
																														   .bind("DTL_ADDR",DTL_ADDR)
																														   .bind("ENTP_DATE", ENTP_DATE)
																														   .bind("ENTP_INDUTY", ENTP_INDUTY)
																														   .bind("EMP_CNT", EMP_CNT)
																														   .bind("SALES_PRICE", SALES_PRICE)
																														   .bind("MAIN_PRODUCT", MAIN_PRODUCT)
																														   .bind("CHRG_NAME", CHRG_NAME)
																														   .bind("CHRG_SN", CHRG_SN)
																														   .bind("CHRG_DEPT", CHRG_DEPT)
																														   .bind("CHRG_DUTY", CHRG_DUTY)
																														   .bind("CHRG_CELL_PHONE", CHRG_CELL_PHONE)
																														   .bind("CHRG_TEL_NO", CHRG_TEL_NO)
																														   .bind("CHRG_MAIL_ADDR", CHRG_MAIL_ADDR)
																														   .bind("DOC_STEP", DOC_STEP)					
																														   .update();

	    	}
	    	
	    	return result;
	    }
	    
	    
	    
	    
	    //------------------------------------------------------------------------------------------------------------------------
	    // step 2 정보 저장
	    //------------------------------------------------------------------------------------------------------------------------
	    public int insertOrUpdateStep2Info(Map<String, Object> commandMap){
	    	int result = 0;
	    	
	    	// 필수항목
	    	String PJT_NAME = commandMap.get("PJT_NAME").toString();	
			String VOUCH_NEEDS = commandMap.get("VOUCH_NEEDS").toString();
			String TECH_NEEDS = commandMap.get("TECH_NEEDS").toString();
			String TECH_DESC = commandMap.get("TECH_DESC").toString();
			String TECH_PLAN = commandMap.get("TECH_PLAN").toString();
			String ATTACH_FILE_ID = commandMap.get("ATTACH_FILE_ID").toString();
			String INFO_AGREE_YN  = commandMap.get("INFO_AGREE_YN").toString();			  
			String UPD_USER = commandMap.get("USER_ID").toString();
			String DOC_STEP = commandMap.get("DOC_STEP").toString();
			String APP_NO = commandMap.get("APP_NO").toString();
	    	
			
			// 비필수항목
			int TOT_GVRN_CNBN = 0;
			String PART_INST_NAME = "-";
			String REQ_ITEMS = "-";
			
			Object obj_TOT_GVRN_CNBN = commandMap.get("TOT_GVRN_CNBN");
			Object obj_PART_INST_NAME = commandMap.get("PART_INST_NAME");
			Object obj_REQ_ITEMS = commandMap.get("REQ_ITEMS");
			
			if(obj_TOT_GVRN_CNBN != ""){
				TOT_GVRN_CNBN = Integer.parseInt(obj_TOT_GVRN_CNBN.toString());
			}
			if(obj_PART_INST_NAME != ""){
				PART_INST_NAME = obj_PART_INST_NAME.toString();
			}
			if(obj_REQ_ITEMS != ""){
				REQ_ITEMS = obj_REQ_ITEMS.toString();
			}
			
				
			result = mapper.query("rndmarket.voucher.RndMarketVoucherMapper.updateStep2").bind("PJT_NAME", PJT_NAME)
																															.bind("TOT_GVRN_CNBN", TOT_GVRN_CNBN)
																															.bind("PART_INST_NAME", PART_INST_NAME)
																															.bind("VOUCH_NEEDS", VOUCH_NEEDS)
																															.bind("TECH_NEEDS", TECH_NEEDS)
																															.bind("TECH_DESC", TECH_DESC)
																															.bind("TECH_PLAN", TECH_PLAN)
																															.bind("REQ_ITEMS", REQ_ITEMS)
																															.bind("ATTACH_FILE_ID", ATTACH_FILE_ID)
																															.bind("INFO_AGREE_YN", INFO_AGREE_YN)
																															.bind("UPD_USER", UPD_USER)
																															.bind("DOC_STEP", DOC_STEP)
																															.bind("APP_NO", APP_NO)
																															.update();
    	
			  
			return result;
	    }
	    
	    
	    
	    //------------------------------------------------------------------------------------------------------------------------
	    //step3 비밀번호 저장
	    //------------------------------------------------------------------------------------------------------------------------
	    public String setPassword(Map<String, Object> commandMap){
	    	int result = 0;
	    	
	    	try{
  		    	String DOC_PASS = commandMap.get("DOC_PASS").toString();
		    	String DOC_STEP = commandMap.get("DOC_STEP").toString();
		    	String APP_NO = commandMap.get("APP_NO").toString();
		    	
		    	result = mapper.query("rndmarket.voucher.RndMarketVoucherMapper.setPassword").bind("DOC_PASS", DOC_PASS)
																					    									  .bind("DOC_STEP", DOC_STEP)
																							    							  .bind("APP_NO", APP_NO)
																							    							  .update();
	    	}catch(NullPointerException e){
	    		e.printStackTrace();
	    		result = -1;
	    	}
	    	
	    	StringBuilder sb = new StringBuilder();
	    	sb.append("{");
	    	sb.append("\"result\":"+result);
	    	sb.append("}");	
	    	
	    	return sb.toString();
	    }
	    
	    
	    
	    
	    //------------------------------------------------------------------------------------------------------------------------
	    // 제출완료 상태변경
	    //------------------------------------------------------------------------------------------------------------------------
	    public String setSubmitStatus(Map<String, Object> commandMap){
 	    	int result = 0;
	    	try{
	    		String APP_NO = commandMap.get("APP_NO").toString();
	    		int overlapCount = mapper.query("rndmarket.voucher.RndMarketVoucherMapper.selectApplyNum").bind("APP_NO", APP_NO).selectOne();
	    		if(overlapCount > 0){
	    			throw new Exception("이미 제출완료된 신청건입니다.");
	    		}
	    		result = mapper.query("rndmarket.voucher.RndMarketVoucherMapper.setSubmitStatus").bind("APP_NO", APP_NO).update();
	    		
	    		if(result > 0){
	    			try {
						sendMail(commandMap);
					} catch (BaseException e) {
						e.printStackTrace();
					}
	    		}
	    		
	    	}catch(NullPointerException e){
	    		result = -1;
	    		e.printStackTrace();
	    	} catch (Exception e) {
				e.printStackTrace();
			}
	    	
	    	StringBuilder sb = new StringBuilder();
    		sb.append("{");
    		sb.append("\"result\":"+result);
    		sb.append("}");
	    	
	    	return sb.toString();
	    }
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    //------------------------------------------------------------------------------------------------------------------------
	    // step01 내용 조회
	    //------------------------------------------------------------------------------------------------------------------------
	    public String selectStep01Data(Map<String, Object> commandMap){
	    	String APP_NO = commandMap.get("APP_NO").toString();
	    	Map<String, Object> selectStep01Data = mapper.query("rndmarket.voucher.RndMarketVoucherMapper.selectApplyHistoryStep01").bind("APP_NO", APP_NO).select();
	    	
	    	String ENTP_NAME = selectStep01Data.get("ENTP_NAME").toString();
	    	String BIZ_REG_NO = selectStep01Data.get("BIZ_REG_NO").toString();
	    	String COR_NO = selectStep01Data.get("COR_NO").toString();
	    	String CEO_NAME = selectStep01Data.get("CEO_NAME").toString();
	    	String COR_PHONE = selectStep01Data.get("COR_PHONE").toString();
	    	String POST_NO = selectStep01Data.get("POST_NO").toString();
	    	String BASE_ADDR = selectStep01Data.get("BASE_ADDR").toString();
	    	String DTL_ADDR = selectStep01Data.get("DTL_ADDR").toString();
	    	String ENTP_DATE = selectStep01Data.get("ENTP_DATE").toString();
	    	String ENTP_INDUTY = selectStep01Data.get("ENTP_INDUTY").toString();
	    	String EMP_CNT = selectStep01Data.get("EMP_CNT").toString();
	    	String SALES_PRICE = selectStep01Data.get("SALES_PRICE").toString();
	    	String MAIN_PRODUCT = selectStep01Data.get("MAIN_PRODUCT").toString();
	    	String CHRG_NAME = selectStep01Data.get("CHRG_NAME").toString();
	    	String CHRG_SN = selectStep01Data.get("CHRG_SN").toString();
	    	String CHRG_DEPT = selectStep01Data.get("CHRG_DEPT").toString();
	    	String CHRG_DUTY = selectStep01Data.get("CHRG_DUTY").toString();
	    	String CHRG_CELL_PHONE = selectStep01Data.get("CHRG_CELL_PHONE").toString();
	    	String CHRG_TEL_NO = selectStep01Data.get("CHRG_TEL_NO").toString();
	    	String CHRG_MAIL_ADDR = selectStep01Data.get("CHRG_MAIL_ADDR").toString();
	    	String DOC_STEP = selectStep01Data.get("DOC_STEP").toString();
	    	
	    	String[] BIZ_REG_NO_Arr = BIZ_REG_NO.split("-");
	    	String[] COR_NO_Arr = null;
	    	if(COR_NO != null){
	    		COR_NO_Arr = COR_NO.split("-");
	    	}
	    	
	    	StringBuilder sb = new StringBuilder();
	    	sb.append("{");
	    	sb.append("\"step01Data\":[{");
	    	sb.append("\"ENTP_NAME\":\""+ENTP_NAME+"\",");
	    	sb.append("\"BIZ_REG_NO_FRONT\":\""+BIZ_REG_NO_Arr[0]+"\",");
	    	sb.append("\"BIZ_REG_NO_MID\":\""+BIZ_REG_NO_Arr[1]+"\",");
	    	sb.append("\"BIZ_REG_NO_REAR\":\""+BIZ_REG_NO_Arr[2]+"\",");
	    	sb.append("\"BIZ_REG_NO\":\""+BIZ_REG_NO+"\",");
	    	if(COR_NO_Arr.length > 0){
		    	sb.append("\"COR_NO_FRONT\":\""+COR_NO_Arr[0]+"\",");
		    	sb.append("\"COR_NO_REAR\":\""+COR_NO_Arr[1]+"\",");
	    	}
	    	sb.append("\"COR_NO\":\""+COR_NO+"\",");
	    	sb.append("\"CEO_NAME\":\""+CEO_NAME+"\",");
	    	sb.append("\"COR_PHONE\":\""+COR_PHONE+"\",");
	    	sb.append("\"POST_NO\":\""+POST_NO+"\",");
	    	sb.append("\"BASE_ADDR\":\""+BASE_ADDR+"\",");
	    	sb.append("\"DTL_ADDR\":\""+DTL_ADDR+"\",");
	    	sb.append("\"ENTP_DATE\":\""+ENTP_DATE+"\",");
	    	sb.append("\"ENTP_INDUTY\":\""+ENTP_INDUTY+"\",");
	    	sb.append("\"EMP_CNT\":\""+EMP_CNT+"\",");
	    	sb.append("\"SALES_PRICE\":\""+SALES_PRICE+"\",");
	    	sb.append("\"MAIN_PRODUCT\":\""+MAIN_PRODUCT+"\",");
	    	sb.append("\"CHRG_NAME\":\""+CHRG_NAME+"\",");
	    	sb.append("\"CHRG_SN\":\""+CHRG_SN+"\",");
	    	sb.append("\"CHRG_DEPT\":\""+CHRG_DEPT+"\",");
	    	sb.append("\"CHRG_DUTY\":\""+CHRG_DUTY+"\",");
	    	sb.append("\"CHRG_CELL_PHONE\":\""+CHRG_CELL_PHONE+"\",");
	    	sb.append("\"CHRG_TEL_NO\":\""+CHRG_TEL_NO+"\",");
	    	sb.append("\"CHRG_MAIL_ADDR\":\""+CHRG_MAIL_ADDR+"\",");
	    	sb.append("\"CHRG_MAIL_ADDR\":\""+CHRG_MAIL_ADDR+"\",");
	    	sb.append("\"DOC_STEP\":\""+DOC_STEP+"\"");
	    	sb.append("}]");
	    	sb.append("}");
	    	
	    	
	    	return sb.toString();
	    }
	    
	    
	    
	    
	    //------------------------------------------------------------------------------------------------------------------------
	    // step02 내용 조회
	    //------------------------------------------------------------------------------------------------------------------------
	    public String selectStep02Data(Map<String, Object> commandMap){
	    	String APP_NO = commandMap.get("APP_NO").toString();
	    	Map<String, Object> selectStep02Data = mapper.query("rndmarket.voucher.RndMarketVoucherMapper.selectApplyHistoryStep02").bind("APP_NO", APP_NO).select();
	    	String PJT_NAME = selectStep02Data.get("PJT_NAME").toString();
	    	int TOT_GVRN_CNBN = 0;
	    	String PART_INST_NAME = selectStep02Data.get("PART_INST_NAME").toString();
	    	String VOUCH_NEEDS = selectStep02Data.get("VOUCH_NEEDS").toString();
	    	String TECH_NEEDS = selectStep02Data.get("TECH_NEEDS").toString();
	    	String TECH_DESC = selectStep02Data.get("TECH_DESC").toString();
	    	String TECH_PLAN = selectStep02Data.get("TECH_PLAN").toString();
	    	String REQ_ITEMS = " ";
	    	String ATTACH_FILE_ID = selectStep02Data.get("ATTACH_FILE_ID").toString();
	    	String INFO_AGREE_YN = selectStep02Data.get("INFO_AGREE_YN").toString();
	    	String DOC_STEP = selectStep02Data.get("DOC_STEP").toString();
	    	String ATTACH_FILE_LINK = selectStep02Data.get("ATTACH_FILE_LINK").toString();
	    	
	    	Object obj_TOT_GVRN_CNBN = selectStep02Data.get("TOT_GVRN_CNBN");
	    	if(obj_TOT_GVRN_CNBN != null){
	    		TOT_GVRN_CNBN = Integer.parseInt(obj_TOT_GVRN_CNBN.toString());
	    	}
	    	Object obj_REQ_ITEMS = selectStep02Data.get("REQ_ITEMS");
	    	if(obj_REQ_ITEMS != null){
	    		REQ_ITEMS = obj_REQ_ITEMS.toString();
	    	}
	    	
	    	StringBuilder sb = new StringBuilder();
	    	sb.append("{");
	    	sb.append("\"step02Data\":[{");
	    	sb.append("\"PJT_NAME\":\""+PJT_NAME+"\",");
	    	sb.append("\"TOT_GVRN_CNBN\":"+TOT_GVRN_CNBN+",");
	    	sb.append("\"PART_INST_NAME\":\""+PART_INST_NAME+"\",");
	    	sb.append("\"VOUCH_NEEDS\":\""+VOUCH_NEEDS+"\",");
	    	sb.append("\"TECH_NEEDS\":\""+TECH_NEEDS+"\",");
	    	sb.append("\"TECH_DESC\":\""+TECH_DESC+"\",");
	    	sb.append("\"TECH_PLAN\":\""+TECH_PLAN+"\",");
	    	sb.append("\"REQ_ITEMS\":\""+REQ_ITEMS+"\",");
	    	sb.append("\"ATTACH_FILE_ID\":\""+ATTACH_FILE_ID+"\",");
	    	sb.append("\"INFO_AGREE_YN\":\""+INFO_AGREE_YN+"\",");
	    	sb.append("\"DOC_STEP\":\""+DOC_STEP+"\",");
	    	sb.append("\"ATTACH_FILE_LINK\":\""+ATTACH_FILE_LINK+"\"");
	    	sb.append("}]");
	    	sb.append("}");
	    	
	    	
	    	return sb.toString();
	    }
	    
	    
	    
	    //------------------------------------------------------------------------------------------------
	    // 매칭 신청 이력 조회  - step03
	    //------------------------------------------------------------------------------------------------
	    public String getApplyHistory(String BIZ_REG_NO, String APP_NO){
	    	 List<Map<String, Object>> voucherList = mapper.query("rndmarket.voucher.RndMarketVoucherMapper.selectApplyHistoryStep03").bind("BIZ_REG_NO", BIZ_REG_NO).bind("APP_NO", APP_NO).selectList();
	    	StringBuilder sb = new StringBuilder();
	    	String GET_BIZ_REG_NO="";
	    	String COR_NO = "";
	    	String[] BIZ_REG_NO_SPLIT = null;
	    	String[] COR_NO_SPLIT = null;
	    	String COR_PHONE = "";
	    	String ENTP_DATE = "";
	    	String ENTP_INDUTY = "";
	    	String EMP_CNT = "";
	    	String SALES_PRICE = "";
	    	String MAIN_PRODUCT = "";
	    	String TOT_GVRN_CNBN = "";
	    	String REQ_ITEMS = "";
	    	
	    	sb.append("{");
	    	sb.append("\"vouchers\":[");
	    	for(int i=0; i<voucherList.size(); i++){
	    		Map<String, Object> voucher = voucherList.get(i);
	    		
	    		try{
		    		GET_BIZ_REG_NO = voucher.get("BIZ_REG_NO").toString();	    		
		    		COR_PHONE = voucher.get("COR_PHONE").toString();
		    		
		    		COR_NO = voucher.get("COR_NO").toString();
		    		ENTP_DATE = voucher.get("ENTP_DATE").toString();
		    		ENTP_INDUTY = voucher.get("ENTP_INDUTY").toString();
		    		EMP_CNT = voucher.get("EMP_CNT").toString();
		    		SALES_PRICE = voucher.get("SALES_PRICE").toString();
		    		MAIN_PRODUCT = voucher.get("MAIN_PRODUCT").toString();
		    		TOT_GVRN_CNBN = voucher.get("TOT_GVRN_CNBN").toString();
		    		REQ_ITEMS = voucher.get("REQ_ITEMS").toString();
		    		
	    		}catch(NullPointerException e){
	    			e.printStackTrace();
	    		}
	    		
	    		BIZ_REG_NO_SPLIT = GET_BIZ_REG_NO.split("-");
	    		COR_NO_SPLIT = COR_NO.split("-");
	    		
		    	sb.append("{");
		    	sb.append("\"APP_NO\":\""+voucher.get("APP_NO")+"\",");
		    	sb.append("\"ENTP_NAME\":\""+voucher.get("ENTP_NAME")+"\",");
		    	sb.append("\"BIZ_REG_NO\":\""+voucher.get("BIZ_REG_NO")+"\",");
		    	sb.append("\"BIZ_REG_NO_FRONT\":\""+BIZ_REG_NO_SPLIT[0]+"\",");
		    	sb.append("\"BIZ_REG_NO_MID\":\""+BIZ_REG_NO_SPLIT[1]+"\",");
		    	sb.append("\"BIZ_REG_NO_REAR\":\""+BIZ_REG_NO_SPLIT[2]+"\",");		   
		    	sb.append("\"COR_NO\":\""+COR_NO+"\",");
		    	if(COR_NO_SPLIT.length != 0){
		    		sb.append("\"COR_NO_FRONT\":\""+COR_NO_SPLIT[0]+"\",");
		    		sb.append("\"COR_NO_REAR\":\""+COR_NO_SPLIT[1]+"\",");
		    	}else{
		    		sb.append("\"COR_NO_FRONT\":\" \",");
		    		sb.append("\"COR_NO_REAR\":\" \",");
		    	}
		    	sb.append("\"CEO_NAME\":\""+voucher.get("CEO_NAME")+"\",");
		    	sb.append("\"COR_PHONE\":\""+COR_PHONE+"\",");
		    	sb.append("\"POST_NO\":\""+voucher.get("POST_NO")+"\",");
		    	sb.append("\"BASE_ADDR\":\""+voucher.get("BASE_ADDR")+"\",");
		    	sb.append("\"DTL_ADDR\":\""+voucher.get("DTL_ADDR")+"\",");
		    	sb.append("\"ENTP_DATE\":\""+ENTP_DATE+"\",");
		    	sb.append("\"ENTP_INDUTY\":\""+ENTP_INDUTY+"\",");
		    	sb.append("\"EMP_CNT\":"+EMP_CNT+",");
		    	sb.append("\"SALES_PRICE\":"+SALES_PRICE+",");
		    	sb.append("\"MAIN_PRODUCT\":\""+MAIN_PRODUCT+"\",");
		    	
		    	sb.append("\"CHRG_NAME\":\""+voucher.get("CHRG_NAME")+"\",");
		    	sb.append("\"CHRG_SN\":\""+voucher.get("CHRG_SN")+"\",");
		    	sb.append("\"CHRG_DEPT\":\""+voucher.get("CHRG_DEPT")+"\",");
		    	sb.append("\"CHRG_DUTY\":\""+voucher.get("CHRG_DUTY")+"\",");
		    	sb.append("\"CHRG_CELL_PHONE\":\""+voucher.get("CHRG_CELL_PHONE")+"\",");
		    	sb.append("\"CHRG_TEL_NO\":\""+voucher.get("CHRG_TEL_NO")+"\",");
		    	sb.append("\"CHRG_MAIL_ADDR\":\""+voucher.get("CHRG_MAIL_ADDR")+"\",");
		    	
		    	sb.append("\"PJT_NAME\":\""+voucher.get("PJT_NAME")+"\",");
		    	sb.append("\"TOT_GVRN_CNBN\":"+TOT_GVRN_CNBN+",");
		    	sb.append("\"PART_INST_NAME\":\""+voucher.get("PART_INST_NAME")+"\",");
		    	sb.append("\"VOUCH_NEEDS\":\""+voucher.get("VOUCH_NEEDS")+"\",");
		    	sb.append("\"TECH_NEEDS\":\""+voucher.get("TECH_NEEDS")+"\",");
		    	sb.append("\"TECH_DESC\":\""+voucher.get("TECH_DESC")+"\",");
		    	sb.append("\"TECH_PLAN\":\""+voucher.get("TECH_PLAN")+"\",");
		    	sb.append("\"REQ_ITEMS\":\""+REQ_ITEMS+"\",");
		    	sb.append("\"ATTACH_FILE_ID\":\""+voucher.get("ATTACH_FILE_ID")+"\",");
		    	sb.append("\"INFO_AGREE_YN\":\""+voucher.get("INFO_AGREE_YN")+"\",");
		    	
		    	sb.append("\"DOC_PASS\":\""+voucher.get("DOC_PASS")+"\",");
		    	sb.append("\"CRE_USER\":\""+voucher.get("CRE_USER")+"\",");
		    	sb.append("\"CRE_DATETIME\":\""+voucher.get("CRE_DATETIME")+"\",");
		    	sb.append("\"UPD_USER\":\""+voucher.get("UPD_USER")+"\",");
		    	sb.append("\"UPD_DATETIME\":\""+voucher.get("UPD_DATETIME")+"\",");
		    	sb.append("\"SEND_MAIL_YN\":\""+voucher.get("SEND_MAIL_YN")+"\",");
		    	sb.append("\"DOC_STEP\":\""+voucher.get("DOC_STEP")+"\",");
		    	if(i<voucherList.size()-1){
		    		sb.append("\"DOC_STATUS\":\""+voucher.get("DOC_STATUS")+"\"},");
		    	}else{
		    		sb.append("\"DOC_STATUS\":\""+voucher.get("DOC_STATUS")+"\"}");		    		
		    	}
	    	}
	    	sb.append("]}");
	    	
	    	System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"+sb.toString());
	    	
	    	return sb.toString();
	    }
	    
	    
	    
	    // 파일 업로드 정보 저장
	    public int InsertFileInfo(String filePath, String fileName, Map<String, Object> commandMap){
	    	int result = mapper.query("rndmarket.voucher.RndMarketVoucherMapper.uploadFileInfoInsert").bind("ATTACH_FILE_LINK", filePath+"/"+fileName)
	    																																.bind("ATTACH_FILE_ID", fileName)
	    																																.bind("APP_NO", commandMap.get("APP_NO").toString())
	    																																.update();
	    	
	    	return result;
	    }
	    
	    
	    
	    
	    
	    
	    
	    
	    
	    
	 // 배장훈 ~~
	    /**
	     * R&D서비스 매칭지원 신청 목록 조회
	     *
	     * @param reqData
	     * @return
	     */
	    public Map<String, Object> retrieveRndVchMatchingApplylist(RequestData reqData, PaginationInfo paginationInfo)
	    {
	        Map<String, Object> result = new HashMap<String, Object>();
	        List<String> applyList = new ArrayList<String>();
	        applyList = mapper.query("rndmarket.voucher.RndMarketVoucherMapper.retrieveRndVchMatchingApplylist").bind(reqData).selectList(paginationInfo);
	        result.put("applyList", applyList);
	        result.put("applyCnt", paginationInfo.getTotalRecordCount());
	        return result;
	    }
	    
	    /** 
	     * R&D서비스 매칭지원 진행상황 변경 처리
	     *
	     * @param reqData
	     */
	    public void updateRndVchMatchingApprov(RequestData reqData)
	    {
	        List<Map<String, String>> rndInfoList = reqData.getList("applyList");
	      
	      
	        for (int i = 0; i < rndInfoList.size(); i++) {
	            Map<String, String> rndInfo = rndInfoList.get(i);
	            System.out.println("*** i *** : " + i);
	            System.out.println("*** DOC_STATUS : " + rndInfo.get("DOC_STATUS"));
	            System.out.println("*** APP_NO : " + rndInfo.get("APP_NO"));
	            mapper.query("rndmarket.voucher.RndMarketVoucherMapper.updateRndMatchingApprovList").bind("DOC_STATUS", rndInfo.get("DOC_STATUS")).bind("APP_NO", rndInfo.get("APP_NO")).update();
	        }
	    }
	    
	    /**
	     * R&D 매칭지원 서비스 상세조회
	     *
	     * @param reqData
	     * @return
	     */
	    public Map<String, Object> retrieveVchApplyDetailInfo(RequestData reqData)
	    {
	        Map<String, Object> result = new HashMap<String, Object>();

	        String app_no = "";
	        app_no = reqData.getParam("APP_NO");
	        
	        result.put("rndInfo", mapper.query("rndmarket.voucher.RndMarketVoucherMapper.retrieveTbVoucherDetail").bind("APP_NO", app_no).select());

//	        if ("".equals(app_no)) {
//	        	app_no = mapper.query("announce.AnnounceMapper.entpIdSearch").bind(reqData).selectOne();
//	            if (null != app_no || "".equals(app_no)) {
//	                result.put("entpInfo", mapper.query("common.enterprise.CommonEnterpriseMapper.retrieveTbComEntp").bind("ENTP_ID", app_no).select());
//	            }
//	        } else {
//	            result.put("entpInfo", mapper.query("common.enterprise.CommonEnterpriseMapper.retrieveTbComEntp").bind("ENTP_ID", app_no).select());
//	        }
	//
//	        result.put("rndInfo", mapper.query("rndmarket.mgmt.RndMarketMgmtMapper.retrieveRndServiceInfo").bind("ENTP_ID", app_no).select());
//	        result.put("requestEntp", mapper.query("rndmarket.mgmt.RndMarketMgmtMapper.retrieveRndServiceRequestInfo").select());
	        return result;
	    }
	    
	    /** 
	     * R&D서비스 매칭지원 상세정보 비밀번호 변경 - 관리자
	     *
	     * @param reqData
	     */
	    public void updateRndVchMatchingPasswd(RequestData reqData)
	    {
	    	List<Map<String, String>> rndInfoList = reqData.getList("applyList");
	    	
	        
	        for (int i = 0; i < rndInfoList.size(); i++) {
	            Map<String, String> rndInfo = rndInfoList.get(i);
	            System.out.println("@@@ DOC_PASS : " + rndInfo.get("DOC_PASS"));
	            mapper.query("rndmarket.voucher.RndMarketVoucherMapper.updateRndMatchingApprovPasswd").bind("DOC_PASS", rndInfo.get("DOC_PASS")).bind("APP_NO", reqData.getParam("APP_NO")).update();
	        }
	    }
}
