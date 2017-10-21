//  This is Jeff LaMarche's GLProgram OpenGL shader wrapper class from his OpenGL ES 2.0 book.
//  A description of this can be found at his page on the topic:
//  http://iphonedevelopment.blogspot.com/2010/11/opengl-es-20-for-ios-chapter-4.html


#import "VLGLProgram.h"

#pragma mark -
#pragma mark Private Extension Method Declaration
@interface VLGLProgram() {
    NSString *_vertexShaderLog;
    NSString *_fragmentShaderLog;
    NSString *_programLog;
}

@end

#pragma mark -
@implementation VLGLProgram


- (id)initWithVertexShaderString:(NSString *)vShaderString 
            fragmentShaderString:(NSString *)fShaderString;
{
    if ((self = [super init])) 
    {
        _initialized = NO;
        
        attributes = [[NSMutableArray alloc] init];
        uniforms = [[NSMutableArray alloc] init];
        program = glCreateProgram();
        
        if (![self compileShader:&vertShader 
                            type:GL_VERTEX_SHADER 
                          string:vShaderString])
        {
            NSLog(@"Failed to compile vertex shader");
        }
        
        // Create and compile fragment shader
        if (![self compileShader:&fragShader 
                            type:GL_FRAGMENT_SHADER 
                          string:fShaderString])
        {
            NSLog(@"Failed to compile fragment shader");
        }
        
        glAttachShader(program, vertShader);
        glAttachShader(program, fragShader);
    }
    
    return self;
}


- (void)dealloc {
    if (vertShader)
        glDeleteShader(vertShader);
    
    if (fragShader)
        glDeleteShader(fragShader);
    
    if (program)
        glDeleteProgram(program);
    
}


- (NSString *)lastLog {
    return [NSString stringWithFormat:@"[VertexShaderLog]: %@\n[FragmentShaderLog]:%@\n[ProgramLinkLog]:%@\n", _vertexShaderLog, _fragmentShaderLog, _programLog];
}


- (BOOL)compileShader:(GLuint *)shader 
                 type:(GLenum)type 
               string:(NSString *)shaderString {
    GLint status;
    const GLchar *source;
    
    source = 
      (GLchar *)[shaderString UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);

	if (status != GL_TRUE) {
		GLint logLength;
		glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
		if (logLength > 0) {
			GLchar *log = (GLchar *)malloc(logLength);
			glGetShaderInfoLog(*shader, logLength, &logLength, log);
            if (shader == &vertShader) {
                _vertexShaderLog = [NSString stringWithFormat:@"%s", log];
                
            } else {
                _fragmentShaderLog = [NSString stringWithFormat:@"%s", log];
            }

			free(log);
		}
	}
    return status == GL_TRUE;
}

#pragma mark -
- (void)addAttribute:(NSString *)attributeName {
    if (![attributes containsObject:attributeName]) {
        [attributes addObject:attributeName];
        glBindAttribLocation(program, 
                             (GLuint)[attributes indexOfObject:attributeName],
                             [attributeName UTF8String]);
    }
}


- (GLuint)attributeIndex:(NSString *)attributeName {
    return (GLuint)[attributes indexOfObject:attributeName];
}

- (GLuint)uniformIndex:(NSString *)uniformName {
    return glGetUniformLocation(program, [uniformName UTF8String]);
}


#pragma mark -

- (BOOL)link {
    GLint status;
    glLinkProgram(program);
    
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if (status == GL_FALSE)
        return NO;
    
    if (vertShader) {
        glDeleteShader(vertShader);
        vertShader = 0;
    }
    if (fragShader) {
        glDeleteShader(fragShader);
        fragShader = 0;
    }
    
    _initialized = YES;
    return YES;
}


- (void)use {
    glUseProgram(program);
}


#pragma mark -

- (void)validate {
	GLint logLength;
	glValidateProgram(program);
	glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0) {
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(program, logLength, &logLength, log);
        _programLog = [NSString stringWithFormat:@"%s", log];
		free(log);
	}	
}

#pragma mark -


@end
