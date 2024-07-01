package web.lab.blood_profile;

import java.io.*;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import com.itextpdf.kernel.geom.PageSize;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Image;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.io.image.ImageDataFactory;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.properties.HorizontalAlignment;
import com.itextpdf.layout.properties.TextAlignment;
import com.itextpdf.kernel.colors.Color;
import com.itextpdf.kernel.colors.DeviceRgb;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.element.Cell;
import org.apache.hc.client5.http.classic.methods.HttpPost;
import org.apache.hc.client5.http.entity.mime.MultipartEntityBuilder;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.CloseableHttpResponse;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.ContentType;
import org.apache.hc.core5.http.ParseException;
import org.apache.hc.core5.http.io.entity.EntityUtils;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.Base64;

public class HelloServlet extends HttpServlet {
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/pdf");

        Part filePart = request.getPart("image");
        String patientID=request.getParameter("id");
        InputStream fileContent = filePart.getInputStream();

        // Step 1: Send image to the API for processing
        JSONObject apiResponse = null;
        try {
            apiResponse = sendImageToFlaskAPI(filePart);
        } catch (JSONException e) {
            throw new RuntimeException(e);
        }

        System.out.println("API Response: " + apiResponse.toString());

        if (!apiResponse.has("processed_image")) {
            throw new RuntimeException("API response does not contain 'processed_image'");
        }


        // Extract processed image and details from API response
        String processedImageBase64 = null;
        try {
            processedImageBase64 = apiResponse.getString("processed_image");
        } catch (JSONException e) {
            throw new RuntimeException(e);
        }
        InputStream processedImageStream = new ByteArrayInputStream(Base64.getDecoder().decode(processedImageBase64));
        TestDetails details = null;
        try {
            details = new TestDetails(apiResponse.getInt("wbc_count"), apiResponse.getInt("rbc_count"), apiResponse.getInt("platelets_count"));
        } catch (JSONException e) {
            throw new RuntimeException(e);
        }

        // Step 2: Add the original image, processed image, and details to the PDF
        ByteArrayOutputStream pdfOutputStream = createPdfWithImageAndText(fileContent, processedImageStream, details,patientID);

        response.setHeader("Content-Disposition", "attachment; filename=\"diagnostic_results.pdf\"");
        OutputStream outputStream = response.getOutputStream();
        pdfOutputStream.writeTo(outputStream);
        outputStream.close();
    }

    private JSONObject sendImageToFlaskAPI(Part filePart) throws IOException, JSONException {
        String flaskUrl = "http://localhost:5000/upload"; // Flask API URL http://localhost:5000/upload

        try (CloseableHttpClient
                     httpClient = HttpClients.createDefault()) {
            HttpPost uploadFile = new HttpPost(flaskUrl);
            MultipartEntityBuilder builder = MultipartEntityBuilder.create();
            builder.addBinaryBody("file", filePart.getInputStream(), ContentType.IMAGE_JPEG, filePart.getSubmittedFileName());
            uploadFile.setEntity(builder.build());

            try (CloseableHttpResponse response = httpClient.execute(uploadFile)) {
                String responseBody = EntityUtils.toString(response.getEntity());
                return new JSONObject(responseBody); // Assuming the Flask API returns a JSON response
            } catch (ParseException e) {
                throw new RuntimeException(e);
            }
        }
    }

    private ByteArrayOutputStream createPdfWithImageAndText(InputStream imageBefore, InputStream imageAfter, TestDetails details, String PatientID) throws IOException {
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();

        try (PdfDocument pdfDoc = new PdfDocument(new PdfWriter(outputStream))) {
            Document doc = new Document(pdfDoc, PageSize.A4);
            Color headerColor = new DeviceRgb(63, 169, 219);

            // Header
            Paragraph header = new Paragraph("Blood Profile Analysis Report")
                    .setTextAlignment(TextAlignment.CENTER)
                    .setFontSize(24)
                    .setBold()
                    .setFontColor(headerColor);
            doc.add(header);

            doc.add(new Paragraph("\n"));

            // Subheader
            Paragraph subheader = new Paragraph("Report Details")
                    .setTextAlignment(TextAlignment.LEFT)
                    .setFontSize(18)
                    .setBold();
            doc.add(subheader);

            // Date and Time
            Paragraph dateTime = new Paragraph("Date: " + java.time.LocalDate.now() + "\nTime: " + java.time.LocalTime.now())
                    .setTextAlignment(TextAlignment.LEFT)
                    .setFontSize(12);
            doc.add(dateTime);

            //ID
            Paragraph identity = new Paragraph("Patient ID: " + PatientID + "\n")
                    .setTextAlignment(TextAlignment.LEFT)
                    .setFontSize(12);
            doc.add(identity);



            doc.add(new Paragraph("\n"));

            // Images Section
            Paragraph imagesHeader = new Paragraph("Microscope Images")
                    .setTextAlignment(TextAlignment.LEFT)
                    .setFontSize(18)
                    .setBold();
            doc.add(imagesHeader);

            // Image Before
            doc.add(new Paragraph("Original Image")
                    .setMarginBottom(5)
                    .setFontSize(14)
                    .setBold());
            doc.add(new Image(ImageDataFactory.create(imageBefore.readAllBytes()))
                    .setWidth(200)
                    .setHorizontalAlignment(HorizontalAlignment.CENTER)
                    .setMarginBottom(15));

            // Image After
            doc.add(new Paragraph("Processed Image")
                    .setMarginBottom(5)
                    .setFontSize(14)
                    .setBold());
            doc.add(new Image(ImageDataFactory.create(imageAfter.readAllBytes()))
                    .setWidth(200)
                    .setHorizontalAlignment(HorizontalAlignment.CENTER)
                    .setMarginBottom(15));

            doc.add(new Paragraph("\n"));

            // Analysis Results
            Paragraph analysisHeader = new Paragraph("Analysis Results")
                    .setTextAlignment(TextAlignment.LEFT)
                    .setFontSize(18)
                    .setBold();
            doc.add(analysisHeader);

            // Table for Cell Counts
            float[] columnWidths = {1, 2};
            Table table = new Table(columnWidths);

            table.addHeaderCell(new Cell().add(new Paragraph("Cell Type").setBold()));
            table.addHeaderCell(new Cell().add(new Paragraph("Count").setBold()));

            table.addCell(new Cell().add(new Paragraph("White Blood Cells (WBC)")));
            table.addCell(new Cell().add(new Paragraph(String.valueOf(details.getWbcCount()))));

            table.addCell(new Cell().add(new Paragraph("Red Blood Cells (RBC)")));
            table.addCell(new Cell().add(new Paragraph(String.valueOf(details.getRbcCount()))));

            table.addCell(new Cell().add(new Paragraph("Platelets")));
            table.addCell(new Cell().add(new Paragraph(String.valueOf(details.getPlateletsCount()))));

            doc.add(table);

            doc.add(new Paragraph("\n"));

            // Explanation Section
            Paragraph explanationHeader = new Paragraph("Explanation")
                    .setTextAlignment(TextAlignment.LEFT)
                    .setFontSize(18)
                    .setBold();
            doc.add(explanationHeader);

            Paragraph explanation = new Paragraph("The above counts represent the detected cells in the provided blood sample image. The processed image shows the detected cells marked for easy identification.")
                    .setFontSize(12)
                    .setMarginBottom(15);
            doc.add(explanation);

            // Caution
            Paragraph caution = new Paragraph("Caution: This is AI-generated results. Use with great caution.")
                    .setTextAlignment(TextAlignment.CENTER)
                    .setItalic()
                    .setFontSize(12)
                    //.setFontColor(Color.RED)
                    .setMarginTop(15);
            doc.add(caution);

            doc.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return outputStream;
    }

    // TestDetails class to store counts
    private class TestDetails {
        private int wbcCount;
        private int rbcCount;
        private int plateletsCount;

        public TestDetails(int wbcCount, int rbcCount, int plateletsCount) {
            this.wbcCount = wbcCount;
            this.rbcCount = rbcCount;
            this.plateletsCount = plateletsCount;
        }

        public int getWbcCount() {
            return wbcCount;
        }

        public int getRbcCount() {
            return rbcCount;
        }

        public int getPlateletsCount() {
            return plateletsCount;
        }
    }

    public void doGet(HttpServletRequest request, HttpServletResponse response){

    }
}
