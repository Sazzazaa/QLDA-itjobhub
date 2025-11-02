import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { CVData, CVDataDocument } from '../../schemas/cv-data.schema';
import { Job, JobDocument } from '../../schemas/job.schema';
import { GeminiService } from '../ai/gemini.service';
import * as fs from 'fs';
import * as pdfParse from 'pdf-parse';
import * as mammoth from 'mammoth';

@Injectable()
export class FilesService {
  constructor(
    @InjectModel(CVData.name) private cvDataModel: Model<CVDataDocument>,
    @InjectModel(Job.name) private jobModel: Model<JobDocument>,
    private geminiService: GeminiService,
  ) {}

  async uploadAndParseCV(userId: string, file: Express.Multer.File): Promise<CVDataDocument> {
    // Save file metadata
    const cvData = new this.cvDataModel({
      userId,
      fileName: file.originalname,
      fileUrl: file.path,
      fileSize: file.size,
      status: 'pending',
    });
    await cvData.save();

    // Parse CV asynchronously
    this.parseCV(cvData._id.toString(), file);

    return cvData;
  }

  private async parseCV(cvId: string, file: Express.Multer.File): Promise<void> {
    try {
      console.log(`🔍 Parsing CV ${cvId}, file: ${file.originalname}, type: ${file.mimetype}`);
      
      // Update status to parsing
      await this.cvDataModel.findByIdAndUpdate(cvId, { status: 'parsing' });

      // Extract text based on file type
      let text = '';
      const fileExtension = file.originalname.toLowerCase().split('.').pop();
      
      // Check by MIME type or file extension
      if (file.mimetype === 'application/pdf' || fileExtension === 'pdf') {
        console.log(`📄 Extracting text from PDF: ${file.path}`);
        const dataBuffer = fs.readFileSync(file.path);
        const data = await pdfParse(dataBuffer);
        text = data.text;
        console.log(`✅ Extracted ${text.length} characters from PDF`);
      } else if (file.mimetype.includes('word') || fileExtension === 'doc' || fileExtension === 'docx') {
        console.log(`📝 Extracting text from Word document: ${file.path}`);
        const result = await mammoth.extractRawText({ path: file.path });
        text = result.value;
        console.log(`✅ Extracted ${text.length} characters from Word doc`);
      } else {
        throw new Error(`Unsupported file type: ${file.mimetype} (extension: ${fileExtension}). Only PDF and Word documents are supported.`);
      }

      // Parse with Gemini AI
      console.log(`🤖 Sending to Gemini AI for parsing...`);
      const parsedData = await this.geminiService.parseCVContent(text);
      console.log(`✅ Gemini AI parsing completed`);

      // Update CV data with parsed results
      await this.cvDataModel.findByIdAndUpdate(cvId, {
        status: 'completed',
        parsedData,
      });
      console.log(`✅ CV ${cvId} parsing completed successfully`);
    } catch (error) {
      console.error(`❌ Error parsing CV ${cvId}:`, error.message);
      await this.cvDataModel.findByIdAndUpdate(cvId, {
        status: 'failed',
        parseError: error.message,
      });
    }
  }

  async getCVStatus(id: string): Promise<CVDataDocument> {
    return this.cvDataModel.findById(id).select('status parseError');
  }

  async getParsedData(id: string): Promise<any> {
    const cvData = await this.cvDataModel.findById(id);
    return cvData.parsedData;
  }

  async getUserCVs(userId: string): Promise<CVDataDocument[]> {
    return this.cvDataModel.find({ userId }).sort({ uploadedAt: -1 });
  }

  async deleteCV(userId: string, cvId: string): Promise<void> {
    const cv = await this.cvDataModel.findOne({ _id: cvId, userId });
    
    if (!cv) {
      throw new Error('CV not found or unauthorized');
    }

    // Delete the file from filesystem
    try {
      if (fs.existsSync(cv.fileUrl)) {
        fs.unlinkSync(cv.fileUrl);
        console.log(`🗑️ Deleted file: ${cv.fileUrl}`);
      }
    } catch (error) {
      console.error(`❌ Error deleting file: ${error.message}`);
    }

    // Delete from database
    await this.cvDataModel.findByIdAndDelete(cvId);
    console.log(`✅ Deleted CV ${cvId} from database`);
  }

  async generateCoverLetter(
    userId: string,
    cvId: string,
    jobId: string,
  ): Promise<{ coverLetter: string }> {
    // Get CV data
    const cv = await this.cvDataModel.findOne({ _id: cvId, userId });
    if (!cv) {
      throw new Error('CV not found or unauthorized');
    }

    if (cv.status !== 'completed' || !cv.parsedData) {
      throw new Error('CV has not been parsed yet. Please wait for parsing to complete.');
    }

    // Get job data
    const job = await this.jobModel.findById(jobId);
    
    if (!job) {
      throw new Error('Job not found');
    }

    console.log(`🤖 Generating cover letter for CV ${cvId} and Job ${jobId}...`);
    
    // Generate cover letter using Gemini
    const coverLetter = await this.geminiService.generateCoverLetter(
      cv.parsedData,
      job.title,
      job.companyName,
      job.description,
      job.requirements,
    );

    console.log(`✅ Cover letter generated successfully`);
    
    return { coverLetter };
  }
}
