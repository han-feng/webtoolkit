package org.xcom.web.filters;

import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.List;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;

/**
 * FilterChain探测器：用于探查运行时FilterChain中Filter的顺序
 * 
 * @author han_feng
 *
 */
public class ChainDetectorFilter implements Filter {

	static final String CATALINA_CHAIN_CLASS = "org.apache.catalina.core.ApplicationFilterChain";
	static final String TONGWEB_CHAIN_CLASS = "com.tongweb.web.core.core.ApplicationFilterChain";

	private static ConcurrentHashMap<String, String[]> cache = new ConcurrentHashMap<String, String[]>();

	private Field filtersField;

	@SuppressWarnings("rawtypes")
	@Override
	public void init(FilterConfig filterConfig) throws ServletException {
		Class filterChainClass = null;
		try {
			filterChainClass = getClass().getClassLoader().loadClass(CATALINA_CHAIN_CLASS);
		} catch (ClassNotFoundException e) {
			// e.printStackTrace();
		}
		if (filterChainClass == null) {
			try {
				filterChainClass = getClass().getClassLoader().loadClass(TONGWEB_CHAIN_CLASS);
			} catch (ClassNotFoundException e) {
				// e.printStackTrace();
			}
		}
		if (filterChainClass != null) {
			try {
				filtersField = filterChainClass.getDeclaredField("filters");
				filtersField.setAccessible(true);
			} catch (SecurityException e) {
				e.printStackTrace();
			} catch (NoSuchFieldException e) {
				e.printStackTrace();
			}
		}
	}

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
			throws IOException, ServletException {
		String url = ((HttpServletRequest) request).getServletPath();
		if (filtersField != null && cache.size() < 100 && cache.get(url) == null) {
			try {
				Object[] objs = (Object[]) filtersField.get(chain);
				List<String> temp = new ArrayList<String>();
				for (Object obj : objs) {
					if (obj != null)
						temp.add(obj.toString());
				}
				cache.put(url, temp.toArray(new String[temp.size()]));
			} catch (IllegalArgumentException e) {
				e.printStackTrace();
			} catch (IllegalAccessException e) {
				e.printStackTrace();
			}
		}

		if ("/filterChainDetector".equals(url)) {
			PrintWriter out = response.getWriter();
			out.println("<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">");
			out.println("<style>table {border-collapse:collapse;border: 0 solid;}");
			out.println("th, td {padding: 5px;}");
			out.println("th {text-align: left;background-color: #ccc;}</style></head>");
			out.println("<body>");
			out.println("FilterChain Class : " + chain.getClass().getName());
			out.print("<table>");
			for (Entry<String, String[]> entry : cache.entrySet()) {
				out.print("<tr><th>");
				out.print(entry.getKey());
				out.println("</th></tr>");
				out.println("<tr><td><ol>");
				for (String filter : entry.getValue()) {
					out.println("<li>" + filter + "</li>");
				}
				out.println("</ol></td></tr>");
			}
			out.println("</table></body></html>");
		} else {
			chain.doFilter(request, response);
		}
	}

	@Override
	public void destroy() {
	}

}
