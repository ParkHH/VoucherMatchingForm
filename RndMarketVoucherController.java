package iitp.ictbay.rndmarket.voucher.web;

import iitp.ictbay.common.abstractmvc.CommonAbstractController;
import iitp.ictbay.common.board.service.CommonBoardService;
import iitp.ictbay.common.main.service.MainService;
import iitp.ictbay.common.util.RequestData;
import iitp.ictbay.rndmarket.voucher.service.RndMarketVoucherService;
import iitp.ictbay.sysmgt.config.codemgt.service.CodeMgtService;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.ws.soap.AddressingFeature.Responses;

import org.apache.commons.io.IOUtils;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import egovframework.rte.ptl.mvc.bind.annotation.CommandMap;
import egovframework.rte.ptl.mvc.tags.ui.pagination.PaginationInfo;

@Controller
public class RndMarketVoucherController extends CommonAbstractController {

	 @Resource(name = "rndMarketVoucherService")
	    private RndMarketVoucherService rndMarketVoucherService;

	    @Resource(name = "codeMgtService")
	    private CodeMgtService codeMgtService;

	    @Resource(name = "mainService")
	    private MainService mainService;
	    
	    @Resource(name = "commonBoardService")
	    private CommonBoardService commonBoardService;

	    
	    
	    
	    //=============================================================================================================================================
	    // >>>> 신청조회화면 관련
	    //=============================================================================================================================================
		//----------------------------------------------------------------------------------------------------------------------------
		// 매칭신청 등록 조회 - 조회화면
		//----------------------------------------------------------------------------------------------------------------------------
	    @RequestMapping("/rndmarket/voucher/getSearchView.do")
	    public String goVoucherApplySearchView(@CommandMap Map<String, Object> commandMap, ModelMap model, @ModelAttribute("PaginationInfo") PaginationInfo paginationInfo){
	        RequestData reqData = super.initListController(commandMap, model, paginationInfo, "rndInfo");
	        String menuId = reqData.getParam("MENU_ID");

	        if(menuId == null || menuId.isEmpty()) {
	            model.addAttribute("viewMenuCode", "ICTP.VOUCHER.APPLY");
	        } else {
	            model.addAttribute("viewMenuCode",menuId);
	        }
	    	 
	    	return "/rndmarket/voucher/RndMarketVoucherApplySearch.jsp";
	     }
	    
	    //----------------------------------------------------------------------------------------------------------------------------
	    // 매칭 신청 이력 조회 - 조회화면
	    //----------------------------------------------------------------------------------------------------------------------------
	    @RequestMapping(value="/rndmarket/voucher/getApplyHistory.do", method=RequestMethod.GET)
	    @ResponseBody
	    public String getApplyHistory(String BIZ_REG_NO, String APP_NO, String DOC_PASS){
	    	String result =  rndMarketVoucherService.getApplyHistory(BIZ_REG_NO, APP_NO);
	    	
	    	return result;
	    }
	    
	    //----------------------------------------------------------------------------------------------------------------------------
	    // 바우처 마지막 일련번호 생성 - 신규작성시 신청번호 채번
	    //----------------------------------------------------------------------------------------------------------------------------
	    public String createNewAPP_NO(){
	    	String new_voucher_apply_num = "";
	    	String num_front = "vm";
	    	String num_front_date = "";
	    	String num_rear = "";
	    	
	    	SimpleDateFormat dateFormate = new SimpleDateFormat("yy-MM-dd");
	    	Date date = new Date();
	    	String today = dateFormate.format(date);
	    	String month = today.substring(3, 5);
	    	String day = today.substring(6, 8);
	    	num_front_date = month + day;
	    	
	    	int nextVoucherNum = rndMarketVoucherService.getNextVoucherNum();
	    	
	    	if(nextVoucherNum < 10){
	    		num_rear = "00"+nextVoucherNum;
	    	}else if(nextVoucherNum <100){
	    		num_rear = "0"+nextVoucherNum;
	    	}
	    	
	    	new_voucher_apply_num = num_front + num_front_date +"-"+ num_rear;
	    	
	    	return new_voucher_apply_num;
	    }
	    
	    
	   //----------------------------------------------------------------------------------------------------------------------------
	   // 매칭신청 등록 상태 check - 이어작성
	   //----------------------------------------------------------------------------------------------------------------------------
	  @RequestMapping("/rndmarket/voucher/getApplyViewStatus.do")
	  public String getVoucherApplyViewStatusList(@CommandMap Map<String, Object> commandMap, ModelMap model, @ModelAttribute("PaginationInfo") PaginationInfo paginationInfo) throws Exception
	  {
		  String page = "";
		  String DOC_STEP = commandMap.get("DOC_STEP").toString();
		  String DOC_STATUS = commandMap.get("DOC_STATUS").toString();
		  String BIZ_REG_NO = commandMap.get("BIZ_REG_NO").toString();
		  String APP_NO = commandMap.get("APP_NO").toString();
	      RequestData reqData = super.initListController(commandMap, model, paginationInfo, "rndInfo");
	      String menuId = reqData.getParam("MENU_ID");
	      if(menuId == null || menuId.isEmpty()) {
	          model.addAttribute("viewMenuCode", "ICTP.VOUCHER.APPLY");
	      } else {
	          model.addAttribute("viewMenuCode",menuId);
	      }
	      
	      String voucherList = rndMarketVoucherService.getApplyHistory(BIZ_REG_NO, APP_NO);
    	  JSONParser parse = new JSONParser();
    	  JSONObject jsonParse =  (JSONObject) parse.parse(voucherList);
    	  JSONArray jsonArr =  (JSONArray) jsonParse.get("vouchers");
    	  JSONObject jsonObject = (JSONObject) jsonArr.get(0);
    	  model.addAttribute("voucherJSON", jsonObject);   
    	  model.addAttribute("APP_NO", APP_NO);
    	  model.addAttribute("DOC_STATUS", DOC_STATUS);
    	  
	      if(DOC_STATUS.equals("01")){		// 작성중
	    	  if(DOC_STEP.equals("01")){
	    		  page="/rndmarket/voucher/RndMarketVoucherApplyView.jsp";	    		  
	    	  }else{
	    		  page="/rndmarket/voucher/RndMarketVoucherApplyView2.jsp";
	    	  }
	      }else if(DOC_STATUS.equals("02") || DOC_STATUS.equals("03") || DOC_STATUS.equals("04") || DOC_STATUS.equals("05") || DOC_STATUS.equals("07")){	// 제출완료, 접수완료, 검토중, 매칭완료
	    	  System.out.println("제출완료, 접수완료, 검토중, 매칭완료");
	    	  page="/rndmarket/voucher/RndMarketVoucherApplyView3.jsp";	
	      }else if(DOC_STATUS.equals("06")){	// 보완요청
	    	  System.out.println("보완요청");
	    	  page="/rndmarket/voucher/RndMarketVoucherApplyView.jsp";
	      }
	
	      return page;
	  }
	    
	    
	    
	    
	    
	    //=============================================================================================================================================
	    // >>>>>>>>>>>>>>> Step 01 페이지 관련
	    //=============================================================================================================================================		
	    //----------------------------------------------------------------------------------------------------------------------------
	    // 매칭신청 등록 첫번째 페이지
	    //----------------------------------------------------------------------------------------------------------------------------
	    @RequestMapping("/rndmarket/voucher/getApplyView.do")
	    public String getVoucherApplyViewList(@CommandMap Map<String, Object> commandMap, ModelMap model, @ModelAttribute("PaginationInfo") PaginationInfo paginationInfo) throws Exception
	    {
	    	System.out.println(">>><<<");
	    	String next_or_prev = commandMap.get("next_or_prev").toString();
	        RequestData reqData = super.initListController(commandMap, model, paginationInfo, "rndInfo");
	        String menuId = reqData.getParam("MENU_ID");
	        Object obj_prevFlag = commandMap.get("prevFlag");
	        String prevFlag = "";
	    	if(obj_prevFlag !=null){
	    		prevFlag = obj_prevFlag.toString();
	    	}
	        
	        // 화면으로 이동을 시도한 동작이 다음/이전 구분하여 동작
	        if(next_or_prev.equals("next")){
	        	// 첫번째 페이지에서 next 일 경우 신규등록이므로 일련번호 채번진행
	        	String new_APP_NO = createNewAPP_NO();
	        	model.addAttribute("APP_NO", new_APP_NO);
	        	model.addAttribute("DOC_STEP", "01");
	        	model.addAttribute("DOC_STATUS", "01");
	    	}else if(next_or_prev.equals("prev") || next_or_prev.equals("none")){
		        String APP_NO = commandMap.get("APP_NO").toString();
		        String voucherList = rndMarketVoucherService.selectStep01Data(commandMap);
		    	JSONParser parse = new JSONParser();
		    	JSONObject jsonParse =  (JSONObject) parse.parse(voucherList);
		    	JSONArray jsonArr =  (JSONArray) jsonParse.get("step01Data");
		    	JSONObject jsonObject = (JSONObject) jsonArr.get(0);
		    	model.addAttribute("voucherJSON", jsonObject);   
		    	model.addAttribute("APP_NO", APP_NO);
		    	model.addAttribute("prevFlag", "true");
	        }
	        
	    	if(menuId == null || menuId.isEmpty()) {
	            model.addAttribute("viewMenuCode", "ICTP.VOUCHER.APPLY");
	        } else {
	            model.addAttribute("viewMenuCode",menuId);
	        }

	        return "/rndmarket/voucher/RndMarketVoucherApplyView.jsp";
	    }
	    
	    //----------------------------------------------------------------------------------------------------------------------------
	    // 사업자 등록 번호 중복 체크
	  	//----------------------------------------------------------------------------------------------------------------------------
	    @RequestMapping(value="/rndmarket/voucher/overlapCheck.do", method=RequestMethod.GET)
	    @ResponseBody
	    public String businessNumOverlapCheck(String BIZ_REG_NO){
	    	String result = rndMarketVoucherService.businessNumOverlapCheck(BIZ_REG_NO);

	    	return result;
	    }
	    
	    
	    
	    
	    //=============================================================================================================================================
	    // >>>>>>>>>>>>>>> Step 02 페이지 관련
	    //=============================================================================================================================================
	    //----------------------------------------------------------------------------------------------------------------------------
	    // 매칭신청 등록 2번째 페이지
	    //----------------------------------------------------------------------------------------------------------------------------
	    @RequestMapping("/rndmarket/voucher/getApplyView2.do")
	    public String getVoucherApplyViewList2(@CommandMap Map<String, Object> commandMap, ModelMap model, @ModelAttribute("PaginationInfo") PaginationInfo paginationInfo) throws Exception
	    {	
	    	String next_or_prev = commandMap.get("next_or_prev").toString();
	    	String DOC_STEP = commandMap.get("DOC_STEP").toString();
	    	String APP_NO = commandMap.get("APP_NO").toString();
	    	Object obj_DOC_STATUS = commandMap.get("DOC_STATUS");	    	
	    	Object obj_prevFlag = commandMap.get("prevFlag");
	    	String DOC_STATUS = "";
	    	String prevFlag = "";
	    	if(obj_DOC_STATUS != null){
	    		DOC_STATUS = obj_DOC_STATUS.toString();
	    	}
	    	if(obj_prevFlag != null){
	    		prevFlag = obj_prevFlag.toString();
	    	}
	    	
	    	// 화면 이동 동작 이전/다음 구분하여 동작
    		if(next_or_prev.equals("next")){
	    		// 넘어온 페이지의 step 을 확인하여 알맞은 동작을 진행
		    	if(DOC_STEP.equals("01")){
		    		// step 01 에 대한 입력 내용 저장
		    		boolean result = InsertOrUpdateStep1Info(commandMap);
		    		if(result){
		    			//step01 입력정보 등록 및 갱신 성공
		    			model.addAttribute("APP_NO", APP_NO);
		    			if(prevFlag.equals("true") || DOC_STATUS.equals("06")){
		    				String voucherList = rndMarketVoucherService.selectStep02Data(commandMap);
		        	    	JSONParser parse = new JSONParser();
		        	    	JSONObject jsonParse =  (JSONObject) parse.parse(voucherList);
		        	    	JSONArray jsonArr =  (JSONArray) jsonParse.get("step02Data");
		        	    	JSONObject jsonObject = (JSONObject) jsonArr.get(0);
		        	    	model.addAttribute("voucherJSON", jsonObject);
		        	    	model.addAttribute("APP_NO", APP_NO);
		    			}
		    		}
		    	}
    		}else if(next_or_prev.equals("prev") || next_or_prev.equals("none")){
    			if(DOC_STATUS.equals("01") || DOC_STATUS.equals("02")){
	    			String voucherList = rndMarketVoucherService.selectStep02Data(commandMap);
	    	    	JSONParser parse = new JSONParser();
	    	    	JSONObject jsonParse =  (JSONObject) parse.parse(voucherList);
	    	    	JSONArray jsonArr =  (JSONArray) jsonParse.get("step02Data");
	    	    	JSONObject jsonObject = (JSONObject) jsonArr.get(0);
	    	    	model.addAttribute("voucherJSON", jsonObject);
	    	    	model.addAttribute("APP_NO", APP_NO);
	    	    	model.addAttribute("prevFlag", "true");
    			}else{
    				return "/rndmarket/voucher/getSearchView.do";
    			}
    		}
    	
	    	
	        RequestData reqData = super.initListController(commandMap, model, paginationInfo, "rndInfo");
	        String menuId = reqData.getParam("MENU_ID");

	        if(menuId == null || menuId.isEmpty()) {
	            model.addAttribute("viewMenuCode", "ICTP.VOUCHER.APPLY");
	        } else {
	            model.addAttribute("viewMenuCode",menuId);
	        }

	        return "/rndmarket/voucher/RndMarketVoucherApplyView2.jsp";
	    }
	    
	    
	    //----------------------------------------------------------------------------------------------------------------------------
	    // 파일 업로드
	    //----------------------------------------------------------------------------------------------------------------------------
	    @RequestMapping(value="/rndmarket/voucher/fileUpload.do", method=RequestMethod.POST)
	    @ResponseBody
	    public String fileUpload(@CommandMap Map<String, Object> commandMap, MultipartFile choose_files){
	    	
	    	int result = 0;
	    	//파일이 저장될 path 설정 
		    //String path = "C:/Users/phh_9/Desktop/IT/30.Program_InstallFile/30.IDE/egovFramework/3.2/eGovFrameDev-3.2.0-64bit/FILE_DOWNLOAD_TEST_FOLDER";
	    	String path = "/usr1/tomcat-7.0.53/XXX:/IITP_ICT-bay/voucher_apply";
	    	String fileName = choose_files.getOriginalFilename();
	    	String ext = fileName.substring(fileName.lastIndexOf('.'));
	    	ModelAndView model = new ModelAndView();
	    	String nextPage = "/WEB-INF/jsp/rndmarket/voucher/RndMarketVoucherApplyView2.jsp";
	    	try{
	    		byte[] uploadFileBytes = choose_files.getBytes();
	    		String savePath = path;
	    		File saveDir = new File(savePath);
	    		if(!saveDir.exists()){
	    			saveDir.mkdirs();
	    		}
	    		Path path_file = Paths.get(savePath, fileName);
	    		Files.write(path_file, uploadFileBytes);
	    		
	    		result = rndMarketVoucherService.InsertFileInfo(path, fileName, commandMap);
	    		if(result <= 0){
	    			File file = new File(savePath+fileName);
	    			file.delete();
	    		}
	    	}catch(Exception e){
	    		e.printStackTrace();
	    	}
	    	
	    	StringBuilder sb = new StringBuilder();
	    	sb.append("{");
	    	sb.append("\"result\":"+result);
	    	sb.append("}");
	    	
	    	
	    	
	    	return sb.toString();
	    }
	    
	    
	    
	  //=============================================================================================================================================
	  // >>>>>>>>>>>>>>> Step 03 페이지 관련
	  //=============================================================================================================================================  
	  //----------------------------------------------------------------------------------------------------------------------------
	  // 매칭 등록 3번째 페이지
	  //----------------------------------------------------------------------------------------------------------------------------
	  @RequestMapping("/rndmarket/voucher/getApplyView3.do")
	  public String getVoucherApplyViewList3(@CommandMap Map<String, Object> commandMap, ModelMap model,  @ModelAttribute("PaginationInfo") PaginationInfo paginationInfo) throws Exception{
		  String next_or_prev = commandMap.get("next_or_prev").toString();
		  String DOC_STEP = commandMap.get("DOC_STEP").toString();
		  String APP_NO = commandMap.get("APP_NO").toString();
		  
		  
		  if(next_or_prev.equals("next")){
			  // 넘어온 페이지의 step 을 확인하여 알맞은 동작을 진행
		    	if(DOC_STEP.equals("02")){
		    		// step 02 에 대한 입력 내용 저장
		    		boolean result = InsertOrUpdateStep2Info(commandMap);
		    		if(result){
		    			//step02 입력정보 등록 및 갱신 성공
		    			model.addAttribute("APP_NO", APP_NO);
		    			
		    			// 입력 내용 조회
		    			String selectStep03Data = rndMarketVoucherService.getApplyHistory(null, APP_NO);
		    			JSONParser parse = new JSONParser();
		    			JSONObject jsonParse =  (JSONObject) parse.parse(selectStep03Data);
		   			  	JSONArray jsonArr =  (JSONArray) jsonParse.get("vouchers");
		   			  	JSONObject jsonObject = (JSONObject) jsonArr.get(0);
		   			  	model.addAttribute("voucherJSON", jsonObject); 
		   			  	model.addAttribute("APP_NO", APP_NO);
		    		}
	    	}  
		  }else if(next_or_prev.equals("none")){
				// 입력 내용 조회
	  			String selectStep03Data = rndMarketVoucherService.getApplyHistory(null, APP_NO);
	  			JSONParser parse = new JSONParser();
	  			JSONObject jsonParse =  (JSONObject) parse.parse(selectStep03Data);
 			  	JSONArray jsonArr =  (JSONArray) jsonParse.get("vouchers");
 			  	JSONObject jsonObject = (JSONObject) jsonArr.get(0);
 			  	model.addAttribute("voucherJSON", jsonObject);
 			  	model.addAttribute("APP_NO", APP_NO);
		  }
	    
		    	
	        RequestData reqData = super.initListController(commandMap, model, paginationInfo, "rndInfo");
	        String menuId = reqData.getParam("MENU_ID");

	        if(menuId == null || menuId.isEmpty()) {
	            model.addAttribute("viewMenuCode", "ICTP.VOUCHER.APPLY");
	        } else {
	            model.addAttribute("viewMenuCode",menuId);
	        }

	        return "/rndmarket/voucher/RndMarketVoucherApplyView3.jsp";
	  }
	  
		  //----------------------------------------------------------------------------------------------------------------------------
		  // 비밀번호 Setting
		  //----------------------------------------------------------------------------------------------------------------------------
		  @RequestMapping(value="/rndmarket/voucher/savePassword.do", method=RequestMethod.POST)
		  @ResponseBody
		  public String setPassword(@CommandMap Map<String, Object> commandMap){
			 String result = rndMarketVoucherService.setPassword(commandMap);
		    	
		    	
		     return result;
		  }
			    
		    //----------------------------------------------------------------------------------------------------------------------------
		    // 제출 상태 Setting
		    //----------------------------------------------------------------------------------------------------------------------------
		    @RequestMapping(value="/rndmarket/voucher/VoucherMatchingSubmit.do", method=RequestMethod.POST)
		    @ResponseBody
		    public String setSubmitStatus(@CommandMap Map<String, Object> commandMap){
		    	String result = rndMarketVoucherService.setSubmitStatus(commandMap);
		    	
		    	return result;
		    }
			    
		    
		    //----------------------------------------------------------------------------------------------------------------------------
		    // 파일 다운로드
		    //----------------------------------------------------------------------------------------------------------------------------
		    @RequestMapping("/rndmarket/voucher/fileDownload.do")
		    public ResponseEntity<byte[]> fileDownload(@CommandMap Map<String, Object> commandMap, HttpServletRequest req, HttpServletResponse res){
		    	File downloadFile = null;
		    	FileInputStream fis = null;
		    	ResponseEntity<byte[]> entity = null;
		    	try {
			    	String APP_NO = commandMap.get("APP_NO").toString();
			    	String step02Data = rndMarketVoucherService.selectStep02Data(commandMap);
			    	JSONParser parser = new JSONParser();
					JSONObject jsonObject = (JSONObject)parser.parse(step02Data);
					JSONArray jsonArr = (JSONArray) jsonObject.get("step02Data");
					JSONObject step02DataArr = (JSONObject)jsonArr.get(0);
					String ATTACH_FILE_ID = step02DataArr.get("ATTACH_FILE_ID").toString();
					String ATTACH_FILE_LINK = step02DataArr.get("ATTACH_FILE_LINK").toString();
					
					downloadFile = new File(ATTACH_FILE_LINK);
					String userAgent = req.getHeader("User-Agent");
					boolean ie = userAgent.indexOf("MSIE") > -1 || userAgent.indexOf("rv:11") > -1;
					String fileName = null;
					if (ie) {
					  fileName = URLEncoder.encode(downloadFile.getName(), "utf-8");
					} else {
					   fileName = new String(downloadFile.getName().getBytes("utf-8"),"iso-8859-1");
				    }
					
					fis = new FileInputStream(downloadFile);
					HttpHeaders headers = new HttpHeaders();
					headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
					headers.add("Content-Disposition", "attatchment; filename=\""+fileName+"\"");
					
					entity = new ResponseEntity<byte[]>(IOUtils.toByteArray(fis), headers, HttpStatus.CREATED);
				} catch (ParseException e) {
					e.printStackTrace();
				} catch (UnsupportedEncodingException e) {
					e.printStackTrace();
				} catch (FileNotFoundException e) {
					e.printStackTrace();
				} catch (IOException e) {
					e.printStackTrace();
				}finally{
					try {
						fis.close();
					} catch (IOException e) {
						e.printStackTrace();
					}
				}
				
		    	return entity;
		    }
		    
		   
		    
    
    
    
    
	    
	    
	    /**
	     * R&D서비스 승인건 통보 메일 발송 처리
	     *
	     * @param commandMap
	     * @param model
	     * @throws Exception
	     */
	    @RequestMapping("/rndmarket/voucher/sendMail.do")
	    public String sendMail(@CommandMap Map<String, Object> commandMap, ModelMap model,@ModelAttribute("PaginationInfo") PaginationInfo paginationInfo) throws Exception
	    {
	        model.addAttribute("viewMenuCode", "ICTP.APPROV");
	        RequestData reqData = super.initListController(commandMap, model, paginationInfo, "rndInfo");
	        rndMarketVoucherService.sendMail(commandMap);

	        return "/rndmarket/approv/RndMarketApprovListR.jsp";
	    }
	 
	    
	    /**
	     * Step1 작성내용 저장하기
	     */
	    public boolean InsertOrUpdateStep1Info(Map<String, Object> commandMap){
	    	int result = rndMarketVoucherService.InsertOrUpdateStep1Info(commandMap);
	    	if(result>0){
	    		return true;
	    	}else{
	    		return false;	    		
	    	}
	    }
	    
	    
	    /**
	     * Step2 작성내용 저장하기
	     */
	    public boolean InsertOrUpdateStep2Info(Map<String, Object> commandMap){
	    	int result = rndMarketVoucherService.insertOrUpdateStep2Info(commandMap);
	    	if(result>0){
	    		return true;
	    	}else{
	    		return false;	    		
	    	}
	    }
	    
	    
	    

		 // 배장훈 ~~
	    
	    /**
	     * R&D서비스 매칭지원 신청 현황
	     *
	     * @param commandMap
	     * @param model	
	     * @throws Exception
	     */
	    @RequestMapping("/rndmarket/voucher/getApplyStateView.do")
	    public String getVoucherMatchingApplyViewList(@CommandMap Map<String, Object> commandMap, ModelMap model,@ModelAttribute("PaginationInfo") PaginationInfo paginationInfo) throws Exception
	    {
    	   model.addAttribute("rndStatus", commonCodeService.retrieveList("RND_VOCH_APPLY_STATUS")); // 진행상황 구분
    	   RequestData reqData = super.initListController(commandMap, model, paginationInfo, "rndInfo");

           model.addAttribute("rndVchAuth", mainService.retrieveRndVchCrtvAuth("RNDADMIN"));       //R&D 바우처 권한

           String menuId = reqData.getParam("MENU_ID");

           if(menuId == null || menuId.isEmpty()) {
               model.addAttribute("viewMenuCode", "ICTP.VOUCHER.APPLYSTATE");
           } else {
               model.addAttribute("viewMenuCode",menuId);
           }
           
           model.addAllAttributes(rndMarketVoucherService.retrieveRndVchMatchingApplylist(reqData,paginationInfo));
	    	   

	       return "/rndmarket/voucher/RndMarketVoucherApplyStateView.jsp";
	    }
	    
	    /**
	     * R&D서비스 매칭서비스 진행상황 변경요청 처리
	     *
	     * @param commandMap
	     * @param model
	     * @throws Exception
	     */
	    @RequestMapping("/rndmarket/voucher/getApprovUpdate.do")
	    public String getVoucherMatchingApprovUpdate(@CommandMap Map<String, Object> commandMap, ModelMap model,@ModelAttribute("PaginationInfo") PaginationInfo paginationInfo) throws Exception
	    {
	        model.addAttribute("viewMenuCode", "ICTP.VOUCHER.APPLYSTATE");
	        RequestData reqData = super.initListController(commandMap, model, paginationInfo, "rndInfo");
	        rndMarketVoucherService.updateRndVchMatchingApprov(reqData);

	        return "/rndmarket/voucher/RndMarketVoucherApplyStateView.jsp";
	    }
	    
	    /**
	     * 상세 화면을 반환한다 수정불가.
	     *
	     * @param commandMap
	     * @param model
	     * @return
	     */
	    @RequestMapping("/rndmarket/voucher/getDetailApplyView.do")
	    public String getDetailVoucherApplyView(@CommandMap Map<String, Object> commandMap, ModelMap model)
	    {
	    	model.addAttribute("viewMenuCode", "ICTP.VOUCHER.APPLYSTATE");
	        RequestData reqData = new RequestData(commandMap);
	        String menuId = reqData.getParam("MENU_ID"); // ICTP.VOUCHER.APPLYSTAT

	        if(menuId == null || menuId.isEmpty()) {
	            model.addAttribute("viewMenuCode","ICTP.VOUCHER.APPLYSTATE");
	        } else {
	            model.addAttribute("viewMenuCode",menuId);
	        }
	        model.addAllAttributes(rndMarketVoucherService.retrieveVchApplyDetailInfo(reqData));


	        model.addAttribute("rndVchAuth", mainService.retrieveRndVchCrtvAuth("RNDADMIN"));       //R&D 바우처 권한
	        
//	        LoginUserVO loginUserVO = CommonUtil.getLoginUserVO();
//	        model.addAttribute("isAdmin",loginUserVO.isAuthCodeUser("SYSADMIN"));
	        return "/rndmarket/voucher/RndMarketVoucherApplyDetailInfo.jsp";
	    }
	    
	    
	    /**
	     * R&D서비스 매칭신청 상세정보 비밀번호 변경 - 관리자
	     *
	     * @param commandMap
	     * @param model
	     * @throws Exception
	     */
	    @RequestMapping("/rndmarket/voucher/updateVchInfoPasswd.do")
	    public String getVoucherMatchingPasswordUpdate(@CommandMap Map<String, Object> commandMap, ModelMap model,@ModelAttribute("PaginationInfo") PaginationInfo paginationInfo) throws Exception
	    {
	        model.addAttribute("viewMenuCode", "ICTP.VOUCHER.APPLYSTATE");
	        RequestData reqData = super.initListController(commandMap, model, paginationInfo, "rndInfo");
	        rndMarketVoucherService.updateRndVchMatchingPasswd(reqData);

	        return "/rndmarket/voucher/RndMarketVoucherApplyStateView.jsp";
	    }
	    
	  
}
