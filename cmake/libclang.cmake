####
# Find clang libraries
####

function(find_llvm_clang_library out_var)
	set(_names ${ARGN})
	find_library(${out_var} NAMES ${_names} PATHS ${LLVM_LIBS_PATH} NO_DEFAULT_PATH)
	if(NOT ${out_var})
		find_library(${out_var} NAMES ${_names} PATHS ${LLVM_LIBS_PATH})
	endif()
endfunction()

if(LIBCLANG_LIBRARIES)
	set(LIBCLANGS_MATCH_SELECTED_LLVM TRUE)
	foreach(_lib ${LIBCLANG_LIBRARIES})
		if(NOT _lib MATCHES "^${LLVM_LIBS_PATH}/")
			set(LIBCLANGS_MATCH_SELECTED_LLVM FALSE)
			break()
		endif()
	endforeach()
	if(NOT LIBCLANGS_MATCH_SELECTED_LLVM)
		message(STATUS "Resetting cached clang libraries from a different LLVM installation")
		unset(LIBCLANG_LIBRARIES CACHE)
		unset(LIBCLANG_LIBRARIES)
	endif()
endif()

set(_libclang_component_vars
	LIBCLANG_LIBRARY_ANALYSIS
	LIBCLANG_LIBRARY_AST
	LIBCLANG_LIBRARY_BASIC
	LIBCLANG_LIBRARY_CODEGEN
	LIBCLANG_LIBRARY_DRIVER
	LIBCLANG_LIBRARY_EDIT
	LIBCLANG_LIBRARY_FRONTEND
	LIBCLANG_LIBRARY_LEX
	LIBCLANG_LIBRARY_PARSE
	LIBCLANG_LIBRARY_SEMA
	LIBCLANG_LIBRARY_SERIALIZATION
	LIBCLANG_LIBRARY_SUPPORT)
foreach(_component_var ${_libclang_component_vars})
	if(${_component_var} AND NOT ${_component_var} MATCHES "^${LLVM_LIBS_PATH}/")
		unset(${_component_var} CACHE)
		unset(${_component_var})
	endif()
endforeach()

if(LIBCLANG_INCLUDE_PATH AND NOT LIBCLANG_INCLUDE_PATH MATCHES "^${LLVM_INCLUDE_PATH}(/|$)")
	message(STATUS "Resetting cached clang headers from a different LLVM installation")
	unset(LIBCLANG_INCLUDE_PATH CACHE)
	unset(LIBCLANG_INCLUDE_PATH)
endif()

if(NOT LIBCLANG_LIBRARIES)
	find_llvm_clang_library(LIBCLANG_LIBRARY_ANALYSIS clangAnalysis libclangAnalysis)
	find_llvm_clang_library(LIBCLANG_LIBRARY_AST clangAST libclangAST)
	find_llvm_clang_library(LIBCLANG_LIBRARY_BASIC clangBasic libclangBasic)
	find_llvm_clang_library(LIBCLANG_LIBRARY_CODEGEN clangCodeGen libclangCodeGen)
	find_llvm_clang_library(LIBCLANG_LIBRARY_DRIVER clangDriver libclangDriver)
	find_llvm_clang_library(LIBCLANG_LIBRARY_EDIT clangEdit libclangEdit)
	find_llvm_clang_library(LIBCLANG_LIBRARY_FRONTEND clangFrontend libclangFrontend)
	find_llvm_clang_library(LIBCLANG_LIBRARY_LEX clangLex libclangLex)
	find_llvm_clang_library(LIBCLANG_LIBRARY_PARSE clangParse libclangParse)
	find_llvm_clang_library(LIBCLANG_LIBRARY_SEMA clangSema libclangSema)
	find_llvm_clang_library(LIBCLANG_LIBRARY_SERIALIZATION clangSerialization libclangSerialization)
	find_llvm_clang_library(LIBCLANG_LIBRARY_ASTMATCHERS clangASTMatchers libclangASTMatchers)
	find_llvm_clang_library(LIBCLANG_LIBRARY_SUPPORT clangSupport libclangSupport)
	
	if(LIBCLANG_LIBRARY_ANALYSIS AND LIBCLANG_LIBRARY_AST AND LIBCLANG_LIBRARY_BASIC AND LIBCLANG_LIBRARY_CODEGEN AND LIBCLANG_LIBRARY_DRIVER AND LIBCLANG_LIBRARY_EDIT AND LIBCLANG_LIBRARY_FRONTEND AND LIBCLANG_LIBRARY_LEX AND LIBCLANG_LIBRARY_PARSE AND LIBCLANG_LIBRARY_SEMA AND LIBCLANG_LIBRARY_SERIALIZATION)
		set(LIBCLANG_LIBRARIES ${LIBCLANG_LIBRARY_ANALYSIS} ${LIBCLANG_LIBRARY_AST} ${LIBCLANG_LIBRARY_BASIC} ${LIBCLANG_LIBRARY_CODEGEN} ${LIBCLANG_LIBRARY_DRIVER} ${LIBCLANG_LIBRARY_EDIT} ${LIBCLANG_LIBRARY_FRONTEND} ${LIBCLANG_LIBRARY_LEX} ${LIBCLANG_LIBRARY_PARSE} ${LIBCLANG_LIBRARY_SEMA} ${LIBCLANG_LIBRARY_SERIALIZATION})
		if(LIBCLANG_LIBRARY_ASTMATCHERS)
			list(APPEND LIBCLANG_LIBRARIES ${LIBCLANG_LIBRARY_ASTMATCHERS})
		endif()
		if(LIBCLANG_LIBRARY_SUPPORT)
			list(APPEND LIBCLANG_LIBRARIES ${LIBCLANG_LIBRARY_SUPPORT})
		endif()
		list(APPEND LIBCLANG_LIBRARIES ${LIBCLANG_LIBRARY_BASIC})
	else()
		# Try shared libclang-cpp.so
		find_library(LIBCLANG_LIBRARIES NAMES clang-cpp libclang-cpp PATHS ${LLVM_LIBS_PATH} NO_DEFAULT_PATH)
		if(NOT LIBCLANG_LIBRARIES)
			find_library(LIBCLANG_LIBRARIES NAMES clang-cpp libclang-cpp PATHS ${LLVM_LIBS_PATH})
		endif()
	endif()
endif()
if(NOT LIBCLANG_INCLUDE_PATH)
	find_path(LIBCLANG_INCLUDE_PATH clang-c/Index.h PATHS ${LLVM_INCLUDE_PATH} NO_DEFAULT_PATH)
	if(NOT LIBCLANG_INCLUDE_PATH)
		find_path(LIBCLANG_INCLUDE_PATH clang-c/Index.h PATHS ${LLVM_INCLUDE_PATH})
	endif()
endif()
if(LIBCLANG_LIBRARIES AND LIBCLANG_INCLUDE_PATH)
	message(STATUS "Using clang libraries: ${LIBCLANG_LIBRARIES}")
	message(STATUS "Using clang headers: ${LIBCLANG_INCLUDE_PATH}")
	set(VC4C_ENABLE_LIBCLANG ON)
else()
	message(WARNING "Clang library precompilation enabled, but no clang libraries were found")
	set(VC4C_ENABLE_LIBCLANG OFF)
endif()
